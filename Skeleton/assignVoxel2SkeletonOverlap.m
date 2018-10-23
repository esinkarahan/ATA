function [assignMat,assignInd,assignMatSkel] = assignVoxel2SkeletonOverlap(V,s)
% Assign the voxels in the tract volume to the skeleton in s
% Skeleton is divided into overlapping pieces so one voxel could be
% assigned to more than one piece of skeleton
% Labeling is performed according to the Euclidian distance
% 
% INPUT
% V -  3D volume
% s - skeleton as a structure element containing X, Y, Z elements
%    s.X, s.Y, s.Z are the fields as 2D matrices
% 
% OUTPUT
% assignMat     - matrix for label of each voxel (nvoxel x 2) 
%               Voxels may have more than one label 
% assignInd     - indices of the voxels that are assigned
% assignMatSkel - matrix for the assigned voxels to each piece (npieces x K)
% 
% Written by Esin Karahan, March, 2018
%

[npiece,npoints] = size(s.X); 
[I,J,K] = ind2sub(size(V),find(V>0));
assignInd = [I,J,K];
% one voxel is supposed to be assigned to several pieces
% Find the distance of voxels to each point in the skeleton
nv = size(I,1);
d = zeros(nv,npiece);
for i=1:npiece
    d(:,i) = min(euclideanDist3([I,J,K],[s.X(i,:)' s.Y(i,:)' s.Z(i,:)']),[],2);
end
% pick the closest segments to assign the voxel
[val,y] = min(d,[],2);
% find how many times val is repeated over pieces
% the first column should be equal to y
assignMat = zeros(nv,2)*NaN;
for i=1:nv
    t = find(d(i,:)==val(i));
    assignMat(i,1:length(t)) = t;
end
assignMatSkel=zeros(npiece,nv);
maxvox = 0;
for i=1:npiece
    [a,b] = ind2sub([nv,2],find(assignMat==i));
    assignMatSkel(i,1:length(a)) = a;
    if maxvox<length(a)
        maxvox = length(a);
    end
end
assignMatSkel=assignMatSkel(:,1:maxvox);
