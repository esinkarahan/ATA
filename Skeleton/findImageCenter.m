function [center] = findImageCenter(im)
% Find the center of the 2D image  
%
% Esin Karahan, January 2018
%
nzInd = find(im>0);
[x,y] = ind2sub(size(im),nzInd);

nz   = size(x,1);
dist = zeros(nz,1); 
for i=1:nz
    for j=1:nz
        dist(i,j) = sqrt(((x(i) - x(j)).^2) + ((y(i) - y(j)).^2));
    end
end

%pick the point which has the minimum distance to everybody
[~,I] = min(sum(dist,2)); 
center = [x(I) y(I)];