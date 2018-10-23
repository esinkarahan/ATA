function [Cfirst,Clast]=findFirstandLastPointsTract(voxel,varargin)
% Find the first and the last points of the tract in the 3D volume
%
% First the orientation of the tract lies is found (x-y, y-z or x-z),
% then the centers of the planes at the proximal points are calculated
% Note that, this function is not good for some of the tracts, e.g. fornix
% since it has a circular shape, in this case it might be better to give
% the row/column/slice number manually
%
% orientation could be given as an input as well, in this case use:
% 1 for leftRight, 2 for rearFront, 3 topDown
%
% Esin Karahan, Jan, 2018

[leftRight, rearFront, topDown] = findBoxVolume(voxel);
box(1,:) = leftRight; box(2,:) = rearFront;
box(3,:) = topDown;

if nargin < 2
    % find the orientation of the image
    [~,ori] = max([diff(leftRight), diff(rearFront), diff(topDown)]);
else
    ori = varargin{1};
end

perm=[1 2 3; 2 1 3; 3 1 2];

fun = @(V,ind) squeeze(V(ind,:,:));
Pfirst = bsxfun(fun,permute(voxel,perm(ori,:)),box(ori,1));
Plast  = bsxfun(fun,permute(voxel,perm(ori,:)),box(ori,2));

Cfirst(perm(ori,:)) = [box(ori,1) findImageCenter(Pfirst)];
Clast(perm(ori,:))  = [box(ori,2) findImageCenter(Plast)];

