function [newskel,in] = limitSkelwithImage(skel,vol)
% Cut the parts of skeleton (skel) that lay outside of the image (vol) 
%
%
% Esin Karahan, May, 2018

ind = find(vol);
[I,J,K] = ind2sub(size(vol),ind);
np = size(skel,1);
in= true(np,1);
for i=1:np
    if all(round(skel(i,1))>I) || all(round(skel(i,2))>J) || all(round(skel(i,3))>K) 
        in(i) = false;
    end
end
display([num2str(sum(~in)) ' point(s) are lying out of the tract'])
newskel = skel(in,:);
