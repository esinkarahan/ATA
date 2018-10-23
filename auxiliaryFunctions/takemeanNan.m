function meanx=takemeanNan(x,d,verbose)
% calculate the mean of a matrix with NaN. 
% NaNs are ignored.
% Esin, November, 2017

if nargin<2
    d=1;
    verbose = 0;
elseif nargin<3
    verbose = 0;
end
if d==2
    x=x';
end
meanx=mean(x);
dnan=isnan(meanx);
ind=find(dnan);
if verbose
    fprintf('There are %d rows/columns with NaN values \n',sum(dnan))
end
for i=1:sum(dnan)
    c=ind(i);
    meanx(c)=mean(x(~isnan(x(:,c)),c));
end
if d==2
    meanx=meanx';
end
