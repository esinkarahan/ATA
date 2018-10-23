function [TconnMatnew,skel_new] = pruneBranchSkel(voxel,connMat,skel,varargin)
% Prune the branches of the skeleton
%
% INPUT:
% voxel   - 3D image
% connMat - connectivity matrix showing which points are connected on the
%            skeleton (npoints x npoints)
% skel    - skeleton (npoints x 3)
% mode    - 'single', 'loop', if it is a loop, the algorithm will continue
%           until there is no branch left. by default it is 'single'
% 
% OUTPUT
% TconnMatnew - revised connectivity matrix
% skel_new    - new skeleton
%
% Esin Karahan, January 2018
% 

if nargin < 4
    mode = 'single';
else 
    mode = varargin{1};
end

nneigh = sum(connMat,2);
branchpoint = find(nneigh<2);
TconnMatnew = connMat;
skel_new = skel;

% find the single connected ones except the 1st and the last in the connectivity
% matrix
branchpoint = branchpoint(2:end-1);
TconnMatnew(branchpoint,:) = [];
TconnMatnew(:,branchpoint) = [];
skel_new(branchpoint,:)=[]; 

nneigh = sum(TconnMatnew,2);
branchpoint = find(nneigh < 2);
if length(branchpoint) > 2 && strcmpi(mode,'loop')
   [TconnMatnew,skel_new] = pruneBranchSkel(voxel,TconnMatnew,skel_new,'loop');
end
