function [skeleton_pos,T] = skel_thinningmethod_mod(voxel, show, rows, cols, slices, XX, YY, ZZ, AZ, EL, rev)
%
% Compute skeleton of input volume data by using Thinning Method. 
%
%
% input:
% voxel: a binary 3D matrix thresholded from original data
% show:  a copy of original voxel. Sometimes voxel has been morphologically 
%        processed or filtered and cannot display as its initial stage
% rows, cols, slices are 3 dimensions of voxel
% XX, YY, ZZ are coordinates of a 3D rectangular grid with the same size of
% original data
% AZ and EL are both view angles of which AZ is the azimuth or horizontal
% rotation and EL is the vertical elevation (both in degrees).
% rev:   a boolean value indicating if the view need to be reversed
%
% ---------------------------
% written by Li Liu in 01/03/2013 
% l.liu6819@gmail.com
%

foldername='Skeleton_results';

updown=zeros(size(voxel));
leftright=zeros(size(voxel));
frontrear=zeros(size(voxel));

for i=1:rows
    temp1=voxel(i,:,:);
    img=reshape(temp1,[cols slices]);
    skeleton1=bwmorph(img,'skel',Inf);
    leftright(i,:,:)=skeleton1;
end

for j=1:cols
    temp2=voxel(:,j,:);
    img=reshape(temp2,[rows slices]);
    skeleton2=bwmorph(img,'skel',Inf);
    frontrear(:,j,:)=skeleton2;
end

for k=1:slices
    temp3=voxel(:,:,k);
    img=reshape(temp3,[rows cols]);
    skeleton3=bwmorph(img,'skel',Inf);
    updown(:,:,k)=skeleton3;
end

%%
full_skeleton = updown & frontrear & leftright;

b=reshape(full_skeleton,prod(size(full_skeleton)),1);
[indx1,indy1,indz1]=ind2sub(size(full_skeleton),find(b==1));
skeleton_pos=[indx1,indy1,indz1];
num_skeleton=size(skeleton_pos,1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Esin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% I added this part to force the skeleton to start from the first and
% finish at the last slices of the tract
% the points to be added:
[Cfirst,Clast]=findFirstandLastPointsTract(voxel);
d1 = sqrt(sum((skeleton_pos - repmat(Cfirst,[num_skeleton 1])).^2,2));
[d2,s]=sort(d1);
skeleton_pos=skeleton_pos(s,:);
skeleton_pos=[Cfirst ; skeleton_pos ; Clast];
num_skeleton= size(skeleton_pos,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

T=connection(voxel, num_skeleton, skeleton_pos, rows, cols, slices);
[m,n]=size(T);

h=figure; %esin
fig_no=h.Number; %6, esin
skel_show3D(XX,YY,ZZ,show,0.5,fig_no,AZ,EL,0.1);
hold on

for i=1:m
    for j=i:n
       
        if T(i,j)==1
            start_x=skeleton_pos(i,2);
            start_y=skeleton_pos(i,1);
            start_z=skeleton_pos(i,3);
            end_x=skeleton_pos(j,2);
            end_y=skeleton_pos(j,1);
            end_z=skeleton_pos(j,3);
            
            plot3([start_x,end_x],[start_y,end_y],[start_z,end_z], '-r','LineWidth',2);
            hold on
        end       
        
    end
end

hold off
title('skeleton of the data');
view(AZ,EL); 
axis tight
if rev==1
    set(gca, 'ZDir','reverse');
end
str='skeleton of the data';
filename = fullfile(foldername, [str '.' 'fig']);  
saveas(gcf, filename);
filename = fullfile(foldername, [str '.' 'jpg']);  
print(gcf, '-djpeg', filename); 

connect_num=sum(sum(T))/2;
[sk_X,sk_Y,sk_Z]=GetSkel(voxel,T,skeleton_pos,connect_num,rows,cols,slices,50);
skel_X=reshape(sk_X, [50, connect_num]);
skel_Y=reshape(sk_Y, [50, connect_num]);
skel_Z=reshape(sk_Z, [50, connect_num]);
skeleton_X=skel_X';
skeleton_Y=skel_Y';
skeleton_Z=skel_Z';

s=struct('Name','data','X',skeleton_X,'Y',skeleton_Y,'Z',skeleton_Z,'AZ',AZ,'EL',EL,'Reverse',rev);
save(fullfile('Skeleton_results','skeleton'), '-struct', 's');

%%
pr = input('Do you want to prune the skeleton of the data?  ([] = yes, n = no, s = sequential pruning) ','s');

skm1 = 0;

while isempty(pr) || strcmp(pr,'s')
    [endpoint,X1,X2]=skel_findendpoint(full_skeleton);
    skeleton = full_skeleton - X2;
    
    sk=skeleton;
    
    for i=2:(rows-1)
        for j=2:(cols-1)
            for k=2:(slices-1)
                tt=sk(i-1:i+1, j-1:j+1, k-1:k+1);
                t=reshape(tt,1,27);         
                
                if sum(t)==1 && sk(i,j,k)==1
                    skeleton(i,j,k)=0;
                end
            end
        end
    end

    b=reshape(skeleton,prod(size(skeleton)),1);
    [indx1,indy1,indz1]=ind2sub(size(skeleton),find(b==1));
    skeleton_pos=[indx1,indy1,indz1];
    num_skeleton=size(skeleton_pos,1);

    T=connection(voxel, num_skeleton, skeleton_pos, rows, cols, slices);
    [m,n]=size(T);

%     skel_show3D(XX,YY,ZZ,show,0.5,7,AZ,EL,0.1);
    skel_show3D(XX,YY,ZZ,show,0.5,fig_no+1,AZ,EL,0.1); %esin
    hold on

    for i=1:m
        for j=i:n
            
            if T(i,j)==1
                start_x=skeleton_pos(i,2);
                start_y=skeleton_pos(i,1);
                start_z=skeleton_pos(i,3);
                end_x=skeleton_pos(j,2);
                end_y=skeleton_pos(j,1);
                end_z=skeleton_pos(j,3);
            
                plot3([start_x,end_x],[start_y,end_y],[start_z,end_z], '-r','LineWidth',2);
                hold on
            end       
        
        end
    end

    hold off
    title('skeleton of the data after pruning');
    view(AZ,EL); 
    axis tight
    if rev==1
        set(gca, 'ZDir','reverse');
    end
    str='skeleton of the data after pruning';
    filename = fullfile(foldername, [str '.' 'fig']);  
    saveas(gcf, filename);
    filename = fullfile(foldername, [str '.' 'jpg']);  
    print(gcf, '-djpeg', filename);
    
    fig_no = fig_no + 1;
    full_skeleton = skeleton;
    
    if sqrt(sum((skm1(:)-sk(:)).^2))==0
        pr='n';
    elseif isempty(pr)
        pr = input('Do you want to prune the skeleton of the data?  ([] = yes, other = no) ','s');
    end
    skm1 = sk;
end

% esin
connect_num=sum(sum(T))/2;
[sk_X,sk_Y,sk_Z]=GetSkel(voxel,T,skeleton_pos,connect_num,rows,cols,slices,50);
skel_X=reshape(sk_X, [50, connect_num]);
skel_Y=reshape(sk_Y, [50, connect_num]);
skel_Z=reshape(sk_Z, [50, connect_num]);
skeleton_X=skel_X';
skeleton_Y=skel_Y';
skeleton_Z=skel_Z';

s=struct('Name','data','X',skeleton_X,'Y',skeleton_Y,'Z',skeleton_Z,'AZ',AZ,'EL',EL,'Reverse',rev);
save(fullfile('Skeleton_results','skeleton'), '-struct', 's');


disp(' ');
disp('All work has been finished!');
disp(' ');

