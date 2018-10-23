function assignMap = assignVoxel2Skeleton(V,skel)
% Assign the voxels in the volume to the skeleton in s according to their
% Euclidean distance to any point in one piece
% 
% INPUT
% V    -  3D volume
% skel -  skeleton as a structure element containing X, Y, Z elements
%         skel.X, skel.Y, skel.Z are the fields as 2D matrices
% 
% OUTPUT
% assignMap -  3D image whose voxels are assigned to the portions in s
%              according to Euclidian distance
%
% Esin Karahan, January, 2018
% 

[rows, cols, slices] = size(V);
[npiece,npoints] = size(skel.X);
assignMap = zeros(rows,cols,slices);
for i = 1:rows
    if sum(sum(V(i,:,:)))
        for j = 1:cols
            for k = 1:slices
                d = sqrt((i-skel.X).^2+(j-skel.Y).^2+(k-skel.Z).^2);
                [~,I]=min(d(:));
                [a,b]=ind2sub([npiece,npoints],I);
                assignMap(i,j,k) = a;
            end
        end
    end
end
assignMap = assignMap.*V;

