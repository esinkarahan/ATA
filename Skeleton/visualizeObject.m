function visualizeObject(vols)
%
% plot 3D objects, including brain images
% multiple images could be plotted on top each other
% visualizeObject({Im1, Im2, ...., ImN})
%
% Esin Karahan, January 2018
%
nimg = 1;
if iscell(vols)
    nimg = length(vols);
else
    vols = {vols};
end

defaultMatlabColour = ...
    [0        0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];

figure();
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
hold off

end