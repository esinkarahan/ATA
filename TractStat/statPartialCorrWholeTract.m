% do stats on the mean values of the metrics on the whole tract
% the stats are written as csv table if one wants to process further in SPSS/JASP
% Written by Esin Karahan, May, 2018
%
close all
clear;
% For adding confidence interval in partial correlation
addpath('nan-3.1.3') 

% set the relevant directories
run('setDirectory.m')
% load definitions
run('setDefinition.m')

defn.bval = '1200';

% load the metrics
load(fullfile(defn.tractstatdir,['wholeTract-thrFA' num2str(defn.thrFA) '-bval' defn.bval], 'meanTractDWI.mat'),'weightMet','meanMet','xyzMet','matMet','numvox');
% sort them
[subjsort,fslsort] = sort(subjs);
% dimensions: (ns,ntr,ndir,5);
weightMetSort = weightMet(fslsort,:,:,:);
meanMetSort   = meanMet  (fslsort,:,:,:);

% load behavioral variables
DM = load(fullfile(defn.behavdir,'designMatDMwithMean.txt')); %B, A, Astd,To, AgeB
load(fullfile(defn.behavdir,'rtfslsortnooutlier')) %RT
RT = takemeanNan(rtfslsortnooutlier);
RT = RT' - mean(RT);
T0 = DM(:,4);
T0m= DM(:,4);
T0 = T0 - mean(T0);
Age= DM(:,5);
Age= Age - mean(Age);

ndti    = 5;
rho     = zeros(ntr,ndir,ndti,2);
pvalglm = zeros(ntr,ndir,ndti,2);
pvalcor = zeros(ntr,ndir,ndti,2);
b0      = zeros(ntr,ndir,ndti,2);
beta    = zeros(ntr,ndir,ndti,2);
betaAge = zeros(ntr,ndir,ndti,2);
tStat   = zeros(ntr,ndir,ndti,2);
ci1   = zeros(ntr,ndir,ndti,2); %confidence interval
ci2   = zeros(ntr,ndir,ndti,2);

dti = {'FA','MD','NDI','ODI','ISO'};
for itr = 1:ntr
    for  idd = 1:ndir
        for idt = 1:ndti
            % mean DTI/NODDI metrics
%             Y = squeeze(meanMetSort(:,itr,idd,idt));
            % weighted DTI/NODDI metrics
            Y = squeeze(weightMetSort(:,itr,idd,idt));
            % RT
            [rho(itr,idd,idt,1),pvalcor(itr,idd,idt,1)] = partialcorr(Y,RT,Age);
            mod = fitglm([RT,Age],Y);
            pvalglm(itr,idd,idt,1) = table2array(mod.Coefficients(2,4));
            b0(itr,idd,idt,1)      = table2array(mod.Coefficients(1,1));
            beta(itr,idd,idt,1)    = table2array(mod.Coefficients(2,1));
            betaAge(itr,idd,idt,1) = table2array(mod.Coefficients(3,1));
            tStat(itr,idd,idt,1)   = table2array(mod.Coefficients(2,3));
            % T0
%             [rho(itr,idd,idt,2),pvalcor(itr,idd,idt,2)] = partialcorr(Y,T0,Age);
            [rho(itr,idd,idt,2),pvalcor(itr,idd,idt,2),ci1(itr,idd,idt,2),ci2(itr,idd,idt,2)] = partcorrcoef(Y,T0,Age);
            mod = fitglm([T0,Age],Y);
            pvalglm(itr,idd,idt,2) = table2array(mod.Coefficients(2,4));
            b0(itr,idd,idt,2)      = table2array(mod.Coefficients(1,1));
            beta(itr,idd,idt,2)    = table2array(mod.Coefficients(2,1));
            betaAge(itr,idd,idt,2) = table2array(mod.Coefficients(3,1));
            tStat(itr,idd,idt,2)   = table2array(mod.Coefficients(2,3));
            
        end
        % write to csv tables to examine later
       dataTable = array2table([RT,T0,Age,squeeze(meanMetSort(:,itr,idd,:))],'VariableNames',{'RT','T0','Age',dti{:}});
       writetable(dataTable,fullfile(destdir,[defn.tr{itr} '-' defn.dir{idd} '.csv']))
    end
end

dti = {'FA','MD','NDI','ODI','ISO'};
% 'OR','CST'
% 'L','R'
pval = 1;
signStatCor = find(pvalcor<pval);
signStatGlm = find(pvalglm<pval);
[trS,dirS,dtiS,behavS] = ind2sub(size(pvalglm),signStatGlm);
[trSc,dirSc,dtiSc,behavSc] = ind2sub(size(pvalcor),signStatCor);
Tglm = table({defn.tr{trS}}',{defn.dir{dirS}}',{dti{dtiS}}',{defn.behav{behavS}}',pvalglm(signStatGlm),beta(signStatGlm),tStat(signStatGlm),'VariableNames',{'Tract','Dir','Metric','RT_T0','pval' 'beta_GLM','tStat'})
Tcor = table({defn.tr{trSc}}',{defn.dir{dirSc}}',{dti{dtiSc}}',{defn.behav{behavSc}}',pvalcor(signStatCor),rho(signStatCor),ci1(signStatCor),ci2(signStatCor),'VariableNames',{'Tract','Dir','Metric','RT_T0','pval' 'rho_PartCorr' 'CI_1' 'CI_2'})


%% Plotting the significant stats
% This requires gramm toolbox developed for Matlab

% Left/Right Together
pval = 0.05;
signStatCor = find(pvalcor<pval);
signStatGlm = find(pvalglm<pval);
[trS,dirS,dtiS,behavS] = ind2sub(size(pvalglm),signStatGlm);
[trSc,dirSc,dtiSc,behavSc] = ind2sub(size(pvalcor),signStatCor);

zz = 1;
HDIR = [repmat({'Left'},[1 ns]) repmat({'Right'},[1 ns])];
g=gramm('x',[DM(:,4)*1000; DM(:,4)*1000],'y',[squeeze(meanMetSort(:,trS(zz),1,dtiS(zz)));squeeze(meanMetSort(:,trS(zz),2,dtiS(zz)))],'color',HDIR);
% Plot raw data as points
g.geom_point('alpha',1)
% Plot linear fits of the data with associated confidence intervals
g.stat_glm('geom','lines')
% Set appropriate names for legends
g.set_names('x','Non-decision time (ms)','y','Neurite Density Index','color','')
g.set_color_options('map',[0 0 1;1 0 0])
g.axe_property('xlim',[100 350],'ylim',[0.6 0.75],...
    'YTick',[0.6 0.65 0.7 0.75]);
% set(ax,'XTickLabel',{'1' '10' '20' '30'});
% Set figure title
g.set_title('Corticospinal Tract')
% Do the actual drawing
g.draw()
