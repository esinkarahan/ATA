%set the directory for the skeleton tract work
rootdir = '~/SampleAnalysis';

if ispc
    addpath('D:\MatlabWork\spm12')
else %it is better to use a unix computer for these analyses
    fslpath  = '/cubric/software/fsl/bin';
    addpath('/cubric/software/fsl/etc/matlab')
end

addpath(fullfile(rootdir,'Codes'))
addpath(fullfile(rootdir,'Codes','Skeleton')) 
addpath(fullfile(rootdir,'Codes','Other','VSK')) 
addpath(fullfile(rootdir,'Codes','Other','splinefit')) 
addpath(fullfile(rootdir,'Codes','Other','shadedErrorBar')) 
addpath(fullfile(rootdir,'Codes','TractStat'))

datadir  = fullfile(rootdir,'Data');
outdir = fullfile(rootdir,'Output');
