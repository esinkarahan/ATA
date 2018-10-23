function s = divideSkel(skel,npiece)
% Divide the skeleton skel into npiece pieces
% 
% INPUT
% skel    - skeleton (npoints x 1)
% npieces - number of pieces 
%
% OUTPUT
% s - structure array with fields X, Y, Z 
%

n = size(skel,1);
if mod(n,npiece)
    K = floor(n/npiece)*npiece;
    fprintf('have to discard the last %d point(s) \n',n-K);
    npoint = K/npiece;
    if (n-K) > npoint
        npiece = floor(n/npoint);
        fprintf('instead increased to %d pieces \n',npiece);
        K = floor(n/npiece)*npiece;
    end
else
    K = n;
end

s.X = reshape(skel(1:K,1),K/npiece,npiece)';
s.Y = reshape(skel(1:K,2),K/npiece,npiece)';
s.Z = reshape(skel(1:K,3),K/npiece,npiece)';
