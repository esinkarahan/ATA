% Calculate the ODI and NDI values (NODDI parameters) along the tract by using the skeleton
% calculated in the previous step
%
% Written by Esin Karahan, February 2018

clear
close all

run('setDirectory.m')
run('setDefinition.m')

defn.dti  = {'meanND','meanODI','weightND','weightODI'};
defn.bval = 'multi';

npiece = defn.npiece;

cmeanND    = cell(ns,ntr,ndir,nskelMethod);
cmeanODI   = cell(ns,ntr,ndir,nskelMethod);
cweightND  = cell(ns,ntr,ndir,nskelMethod);
cweightODI = cell(ns,ntr,ndir,nskelMethod);
cvoxperSeg = cell(ns,ntr,ndir,nskelMethod);

nvox = 500;

matnd  = zeros(ns,ntr,ndir,nskelMethod,npiece,nvox);
matodi = zeros(ns,ntr,ndir,nskelMethod,npiece,nvox);
xyznd  = zeros(ns,ntr,ndir,nskelMethod,npiece,nvox,3);
xyzodi = zeros(ns,ntr,ndir,nskelMethod,npiece,nvox,3);

% Neurite density (or intra-cellular volume fraction): example_ficvf.nii
% Orientation dispersion index (ODI): example_odi.nii

tic
for isubj = 1:ns
    subjname = subjs{isubj};
    fprintf(' Subject %s - ',subjname)

    % use the FA images for thresholding so that FA and NODDI parameters
    % would be in the same space
    nFA   = fullfile(defn.dwidir,subjname,['dti_',defn.bval,'_FA_ero.nii.gz']);
    imFA  = read_avw(nFA);
    % Do not use the voxel with FA values greater than 1 due to low SNR
    imFA(imFA>1) = 0;

    %threshold the FA
    maskInd = (imFA<defn.thrFA);

    % load noddi images
    nND   = fullfile(defn.noddidir,subjname,[subjname '_noddi_ficvf.nii.gz']);
    imND  = read_avw(nND);
    imND(maskInd) = 0;
    
    nODI  = fullfile(defn.noddidir,subjname,[subjname '_noddi_odi.nii.gz']);
    imODI = read_avw(nODI);
    imODI(maskInd) = 0;

    % mask with the registered white matter maps
    nWM  = fullfile(defn.dwidir,subjname,[subjname '_seg_2_2_native.nii.gz']);
    imWM = read_avw(nWM);
    imND = imND.*imWM;
    imODI= imODI.*imWM;
    
    for itr = 1:length(defn.tr)
        for  idd = 1:length(defn.dir)
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
                ntractMask = fullfile(defn.outdir,tractFol,['ANDmasksubjectsAssignMap' defn.skelMethod{im} num2str(npiece) '.nii']);

                % Segments are overlapping so that each subvolume/segment
                % is registered to subject space separately
                ntractSkelInfo = fullfile(defn.outdir,tractFol,['SkelOverlap' defn.skelMethod{im} num2str(npiece) '.mat']);
                [cmeanND{isubj,itr,idd,im},cweightND{isubj,itr,idd,im},cmeanODI{isubj,itr,idd,im},cweightODI{isubj,itr,idd,im},cvoxperSeg{isubj,itr,idd,im},mnd,modi,xyznds,xyzodis] ...
                    =averageFAMDtractSkeletonOverlapReg(imND,imODI,imfdt,ntractMask,ntractSkelInfo,subjname,defn);
                [a,b]=size(mnd);
                % size: (ns,ntr,ndir,nskelMethod,npiece,nvox);
                matnd(isubj,itr,idd,im,1:a,1:b) = mnd; 
                matodi(isubj,itr,idd,im,1:a,1:b) = modi; 
                [a,b,c]=size(xyznds);
                xyznd(isubj,itr,idd,im,1:a,1:b,1:c)= xyznds;
                xyzodi(isubj,itr,idd,im,1:a,1:b,1:c)= xyzodis;
            end
        end
    end
end
toc

% save the results
% NODDI works only for multishell data
dest = fullfile(defn.tractstatdir,['segment' num2str(npiece) '-thrFA' num2str(defn.thrFA) '-bvalmulti']);
mkdir(dest)
save(fullfile(dest,['alongTractDWI-NODDI-' num2str(npiece) '.mat']),...
    'cmeanND','cmeanODI','cweightND','cweightODI','cvoxperSeg','matnd','matodi','xyznd','xyzodi')

% save the results in txt files
saveAlongTractMetricsTxt(cmeanND,cmeanODI,cweightND,cweightODI,subjs,npiece,defn)

% For plotting the results
defn.metric = {'Mean NDI','Mean ODI', 'Weighted NDI', 'Weighted ODI'};
plotAlongTractMetrics(cweightND,defn,'Weighted NDI')
plotAlongTractPaper(cweightODI,defn,'Weighted ODI')