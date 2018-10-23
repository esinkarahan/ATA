function visualizeObjectSkel(vols,skels,varargin)
% Plot 3D objects with their skeletons
% Multiple objects or skeletons are plotted if they are cell array
% If the connectivity matrix of the skeleton is provided, the points of the
% skeleton in 3D are connected to each other according to this matrix
%
% Esin Karahan, January 2018
%
if nargin < 3
    connMat = 0;
    textf   = 0;
else
    connMat = varargin{1};
    textf = 0;
end

if nargin < 4
    textf = 0;
else
    textf = varargin{1};
end

nimg = 1;
if iscell(vols)
    nimg = length(vols);
else
    vols = {vols};
end

nskel = 1;
if iscell(skels)
    nskel = length(skels);
else
    skels = {skels};
end

% volumes will be constructed in this colors
defaultMatlabColour = ...
    [0        0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];


figure();
% visualize objects
for i = 1:nimg
    col   = defaultMatlabColour(i,:);
    vol1  = vols{i};
    hiso  = patch(isosurface(vol1,0),'FaceColor',col,'EdgeColor','none');
    axis equal;axis off;
    lighting phong;
    isonormals(vol1,hiso);
    alpha(0.5);
    set(gca,'DataAspectRatio',[1 1 1])
    camlight;
    set(gcf,'Color','white');
    view(-240,0)
    hold on
end
% visualize skeletons
for isk = 1:nskel
    skel = skels{isk};
    if length(size(skel))==3
        % if skeleton is a 3D object as well
        w=size(skel,1);
        l=size(skel,2);
        h=size(skel,3);
        [x,y,z]=ind2sub([w,l,h],find(skel(:)));
    else
        x=skel(:,1);
        y=skel(:,2);
        z=skel(:,3);
    end
    
    if sum(size(connMat)>1)
        % if we know how the points in the skeleton are connected
        [m,n] = size(connMat);
        for i=1:m
            for j=i:n
                if connMat(i,j)==1
                    start_x=skel(i,2);
                    start_y=skel(i,1);
                    start_z=skel(i,3);
                    end_x=skel(j,2);
                    end_y=skel(j,1);
                    end_z=skel(j,3);
            plot3([start_x,end_x],[start_y,end_y],[start_z,end_z], '-rs','LineWidth',2, 'MarkerEdgeColor','k', 'MarkerFaceColor','y',  'MarkerSize',3);
                    hold on
                end
            end
        end
    else
        plot3(y,x,z,'k.','MarkerSize',10);
        view(-240,0)
        if textf
            % if the points of the skeleton will be added as a text
            text(skel(i,2),skel(i,1),skel(i,3),{num2str(i)})
            hold on
        end
    end
    hold on
end

set(gcf,'Color','white');
hold off
axis tight
end