function [newCurve, Tnew] = spline3dCurveInterpolation(curve, npiece, order) 
% Interpolate a 3D curve using splines
% 
% plots the original and interpolated curve in the same figure
%
% INPUT
% curve   - 3D line (npoints x 3)
% npiece  - number of points in the interpolated line
% order   - order of the spline interpolation, (4)
%
% Written by Esin Karahan, January 2018
%
% using splinefit toolbox from Jonas Lundgren (2017)
%

% order 4 is cubic spline
if ~exist('order','var')
    order = 4;
end

% compute the min distance between 2 curve pos
I = size(curve,1);
d = zeros(I-1,1);
for i=1:I-1
    d(i)=sqrt(sum((curve(i+1,:)-curve(i,:)).^2));
end

totalLength = sum(d);

dt = totalLength/npiece;

x = curve(:, 1); 
y = curve(:, 2); 
z = curve(:, 3);

t = cumsum([0;sqrt(diff(x(:)).^2 + diff(y(:)).^2 + diff(z(:)).^2)]); 
tt = t(1):dt:t(end); 

% give constraints to fix the first point
xc = t(1); yc = x(1);con = struct('xc',xc,'yc',yc);
% Fit a cubic spline with 2 pieces and constraints
sx = splinefit(t,x,2,order,con,'r');
xp = ppval(sx,tt);
% figure,plot(tt,xp,'.',t,x,'o')
xc = t(1); yc = y(1);con = struct('xc',xc,'yc',yc);
sy = splinefit(t,y,2,order,con,'r');
yp = ppval(sy,tt);
% figure,plot(tt,yp,'.',t,y,'o')
xc = t(1); yc = z(1);con = struct('xc',xc,'yc',yc);
sz = splinefit(t,z,2,order,con,'r');
zp = ppval(sz,tt);
% figure,plot(tt,zp,'.',t,z,'o')
newCurve = [xp'  yp'  zp']; 
newCurve = newCurve(1:end-1,:);

% assuming curve is a line
n = length(tt)-1;
Tnew = full(spdiags([ones(n,1) zeros(n,1) ones(n,1)],[-1 0 1],n,n)); 

figure,plot3(curve(:,1),curve(:,2),curve(:,3),'r')
hold on
plot3(xp,yp,zp,'g*')
hold off
axis tight
set(gcf,'Color','white');
view(-240,0)
set(gca,'DataAspectRatio',[1 1 1])
camlight;
