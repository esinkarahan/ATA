function semx = takesemNan(x,d)
% calculate the standard error of the mean (sem) of a matrix with NaN. 
% NaNs are ignored.
% note that sem = std/sqrt(n)
% Esin, October, 2018

if nargin<2
    d=1;
end
if d==2
    x=x';
end
nsample = size(x,1);
stdx=std(x);
semx=stdx/sqrt(nsample);
dnan=isnan(stdx);
ind=find(dnan);
fprintf('%d columns/rows have NaN values \n',sum(dnan))
for i=1:sum(dnan)
    c=ind(i);
    stdx(c)=std(x(~isnan(x(:,c)),c));
    semx(c)=stdx(c)./sqrt(nsample);
end
if d==2
    semx=semx';
end
