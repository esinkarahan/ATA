function [ub,lb] = bootciMeanNan(x)
% calculate the 95% CI of the mean by using matlab bootstrapping 
% NaNs are ignored.
% Esin, October, 2018


nboot = 5000;
ci = bootci(nboot,@takemeanNan,x);
%return upper-lower
lb = takemeanNan(x) - ci(1,:);
ub = ci(2,:) - takemeanNan(x);
