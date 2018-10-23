function s = divideSkelOverlap(skel,npiece,winf)
% Divide the skeleton into overlapping pieces
% |----- |-----|-----|
% |---||--|---||--|---||--|
%
% INPUT
% skel   - skeleton (npoints x 3)
% npiece - number of pieces  
% winf   - percentage/absolute number that denotes the overlapping portions
%
% OUTPUT
% s      - structure array with X,Y,Z fields each have npieces x npoints
%           dimension
%
% Written by Esin Karahan, March, 2018

K = size(skel,1);
if winf < 1
    % win denotes the percentage of overlapping points
    npoint = floor(K/npiece);
    win    = floor(npoint * winf);
else
    % win denotes the number of overlapping points
    win = winf;
    npoint = floor(K/npiece);
end

s.ind = 1:npoint;
while (s.ind(end) < K) && ~isnan(s.ind(end))
    s.ind = 1:npoint;
    zf = npoint;
    for i = 2:npiece
        zi = zf - win;
        s.ind(i,:) = zi+1:zi+npoint;
        zf = zi + npoint;
        if zf > K
            break;
        end
    end
    s.ind(s.ind > K) = NaN;
    npoint = npoint + 1;
    if winf < 1
        win = floor(npoint*winf);
    end
end

num = sum(sum(isnan(s.ind)));
t   = s.ind';
s.X = reshape([skel(t(~isnan(t)),1); ones(num,1)*NaN],size(t))';
s.Y = reshape([skel(t(~isnan(t)),2); ones(num,1)*NaN],size(t))';
s.Z = reshape([skel(t(~isnan(t)),3); ones(num,1)*NaN],size(t))';
