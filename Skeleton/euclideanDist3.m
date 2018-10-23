function d = euclideanDist3(X,Y)
% Calculate the elementwise Euclidean distance between two matrices
% 
% INPUTS
% Dimensions of X(ix by 3) and Y (iy by 3) 
%
% OUTPUT
% Dimension of d (ix by iy)
%
% Written by Esin Karahan, March 2018
%

[ix,jx] = size(X);
[iy,jy] = size(Y);

if jx ~= jy
    display('Column number of arrays should be equal')
    return
end

d = zeros(ix,iy);
for i=1:ix
      d(i,:) = sqrt(sum((repmat(X(i,:),[iy 1]) - Y).^2,2));
end

