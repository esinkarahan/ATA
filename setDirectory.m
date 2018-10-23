%set the diroctory for the skeleton tract work
rootdir = '/home/sapek5/Desktop/SampleAnalysis';

if ispc
    addpath('D:\MatlabWork\spm12')
    addpath('C:\Users\esink\Dropbox\Matlab\shadedErrorBar')
else
    fslpath  = '/cubric/software/fsl/bin';
    addpath('/cubric/software/fsl/etc/matlab')
end

addpath(fullfile(rootdir,'Codes'))
addpath(fullfile(rootdir,'Codes','Skeleton')) 
addpath(fullfile(rootdir,'Codes','Other','VSK')) 
addpath(fullfile(rootdir,'Codes','Other','splinefit')) 
addpath(fullfile(rootdir,'Codes','TractStat'))

datadir  = fullfile(rootdir,'Data');
outdir   = fullfile(rootdir,'Output');
