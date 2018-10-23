function [Tnew,skelnew] = organizeSkelLine (T,skel)
% Reorganize the skel according to the connectivity matrix so that the order
% of the skeleton in the skel variable is the same as its geometrical
% location
%
% INPUT
% T     - connectivity matrix showing which points are connected on the
%     skeleton (npoints x npoints)
% skel  - skeleton (npoints x 3)
%
% Esin Karahan, January 2018
% 

[m,n] = size(T);
neigh = sum(T,2);
pp = find(neigh==1);
pp = pp(1);

order = zeros(n,1);
order(1) = pp;
k=pp;
for i=2:m
    b = find(T(k,:));
    k = setdiff(b,order);
    order(i) = k;
    k = k(end);
 end

% now the skeleton is a line
Tnew = full(spdiags([ones(n,1) zeros(n,1) ones(n,1)],[-1 0 1],n,n)); 
skelnew = skel(order,:);

