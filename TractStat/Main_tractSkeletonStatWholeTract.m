% Calculate the FA and MD values along the WHOLE tract 
% Mean and Weighted values of the whole tract is reported
% The same volumes/tracts (XXXXXCropBin.nii.gz) that are accounted for in
% the skeletonization operation are used here as well.
%
% Written by Esin Karahan, May 2018

clear;
close all

run('setDirectory.m')
run('setDefinition.m')

npiece = defn.npiece;

% subject x number of tracts x Left/Right x number of metrics
weightMet = zeros(ns,ntr,ndir,4);
meanMet   = zeros(ns,ntr,ndir,4);
numvox    = zeros(ns,ntr,ndir,4);
xyzMet    = cell(ns,ntr,ndir,4); 
matMet    = cell(ns,ntr,ndir,4); 

tic
for isubj = 1:ns
    subjname = subjs{isubj};
    fprintf(' Subject %s - ',subjname)

    % mask with the registered white matter maps
    nWM  = fullfile(defn.dwidir,subjname,[subjname '_seg_2_2_native.nii.gz']);
    imWM = read_avw(nWM);

    %%%% FA %%%%%%%%
    nFA   = fullfile(defn.dwidir,subjname,['dti_',defn.bval,'_FA_ero.nii.gz']);
    imFA  = read_avw(nFA);
    imFA(imFA<defn.thrFA) = 0;     %threshold the FA
    % Do not use the voxel with FA values greater than 1 due to low SNR
    imFA(imFA>1) = 0;
    imFA = imFA.*imWM;
    %%%% MD %%%%%%%%
    nMD   = fullfile(defn.dwidir,subjname,['dti_',defn.bval,'_MD.nii.gz']);
    imMD  = read_avw(nMD);
    imMD(imFA==0)=0;    % use the same voxels
    imMD = imMD.*imWM;
    %%%% NDI %%%%%%%%
    nND   = fullfile(defn.noddidir,subjname,[subjname '_noddi_ficvf.nii.gz']);
    imND  = read_avw(nND);
    imND(imFA==0) = 0;
    imND = imND.*imWM;
    %%%% ODI %%%%%%%%
    nODI  = fullfile(defn.noddidir,subjname,[subjname '_noddi_odi.nii.gz']);
    imODI = read_avw(nODI);
    imODI(imFA==0) = 0;
    imODI= imODI.*imWM;
    
    for itr = 1:ntr
        for  idd = 1:ndir
            fprintf('Tract: %s Dir: %s \n',defn.tr{itr}, defn.dir{idd})
            if strcmp(defn.tr{itr},'OR-way'), a = 1; else a = 2; end
            if strcmp(defn.dir{idd},'L'),     b = 1; else b = 2; end
            
            nVoxSeed   = defn.nVoxSeedAll(a,b);
            tractFol   = [defn.tr{itr} '-' defn.dir{idd} '.probtrackX.' defn.regMethod '.Stop'];
            
            % registered fdt paths
            regfdt = fullfile(defn.trackdir,[subjname '.' tractFol],'fdt_paths_reg.nii.gz');
            imfdt  = read_avw(regfdt);
            nTotalBrain = sum(imfdt(:));
            
            % use fixed threshold for all subjects
            thr_fdt = round(nVoxSeed * defn.nSamples * defn.thrSet);
            imfdt(imfdt < thr_fdt) = 0;
            
            % calculate the probability of each voxel to be in the
            % tractography
            nTotalStreamlines = nVoxSeed * defn.nSamples;
            imfdt  = (imfdt./(nTotalStreamlines))/((nTotalBrain)/nTotalStreamlines);
            
            for im = 1:length(defn.skelMethod)
                ntractMask     = fullfile(defn.outdir,tractFol,'ANDmasksubjectsProbCropBin.nii.gz');
                [weightMet(isubj,itr,idd,:),meanMet(isubj,itr,idd,:),xyzMet(isubj,itr,idd,:),matMet(isubj,itr,idd,:),numvox(isubj,itr,idd,:)]=averagetract(imFA,imMD,imND,imODI,imfdt,ntractMask,subjname,defn);
            end
        end
    end
end
toc
% save the results
dest = fullfile(defn.tractstatdir,['wholeTract-thrFA' num2str(defn.thrFA) '-bval' defn.bval]);
mkdir(dest)
save(fullfile(dest,'meanTractDWI.mat'),'weightMet','meanMet','xyzMet','matMet','numvox');
