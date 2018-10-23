function [leftRight, rearFront, topDown] = findBoxVolume(V)
% Find the box that a 2D image is located. 
% In fact this is equal to finding the tippest points in all dimensions
%
% Esin Karahan, January 2018
%
tips = zeros(3,2);

for i = 1:3
    left = [];
    right = [];
    Vp = permute(V,[i [1:i-1 i+1:3]]);
    for j=1:size(V,i)
        if sum(sum(Vp(j,:,:))) && isempty(left)
          tips(i,1) = j;
          left = 'y';
        elseif ~sum(sum(Vp(j,:,:))) && isempty(right) && ~isempty(left)
          tips(i,2) = j-1;
          right = 'y';
        end
    end
end

leftRight = tips(1,:);
rearFront = tips(2,:);
topDown = tips(3,:);
