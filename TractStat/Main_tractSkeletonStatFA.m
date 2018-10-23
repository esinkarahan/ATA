% Calculate the FA and MD values along the tract by using the skeleton
% calculated in the previous step
%
% Written by Esin Karahan, Jan 2018

clear
close all

run('setDirectory.m')
run('setDefinition.m')

npiece = defn.npiece;

% subject x number of tracts x Left/Right x SkeletonizationMethod
cmeanFA   = cell(ns,ntr,ndir,nskelMethod);
cmeanMD   = cell(ns,ntr,ndir,nskelMethod);
cweightFA = cell(ns,ntr,ndir,nskelMethod);
cweightMD = cell(ns,ntr,ndir,nskelMethod);
cvoxperSeg= cell(ns,ntr,ndir,nskelMethod);

% arbitray and big enough number to save the voxels in each segment
nvox = 500;

matfa = zeros(ns,ntr,ndir,nskelMethod,npiece,nvox);
matmd = zeros(ns,ntr,ndir,nskelMethod,npiece,nvox);
xyzfa = zeros(ns,ntr,ndir,nskelMethod,npiece,nvox,3);
xyzmd = zeros(ns,ntr,ndir,nskelMethod,npiece,nvox,3);

tic
for isubj = 1:ns
    subjname = subjs{isubj};
    fprintf(' Subject %s - ',subjname)

    % Load the FA and MD maps
    nFA   = fullfile(defn.dwidir,subjname,['dti_',defn.bval,'_FA_ero.nii.gz']);
    nMD   = fullfile(defn.dwidir,subjname,['dti_',defn.bval,'_MD.nii.gz']);
    imFA  = read_avw(nFA);
    imMD  = read_avw(nMD);
    
    % threshold the FA
    imFA(imFA<defn.thrFA) = 0;
    
    % Do not use the voxel with FA values greater than 1 due to low SNR
    imFA(imFA>1) = 0;
    % Use the same voxels for MD
    imMD(imFA==0)=0;
    
    % mask with the registered white matter maps
    nWM  = fullfile(defn.dwidir,subjname,[subjname '_seg_2_2_native.nii.gz']);
    imWM = read_avw(nWM);
    imFA = imFA.*imWM;
    imMD = imMD.*imWM;
    
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
                ntractMask = fullfile(defn.outdir,tractFol,['ANDmasksubjectsAssignMap' defn.skelMethod{im} num2str(npiece) '.nii']);
    
                % Segments are overlapping so that each subvolume/segment
                % is registered to subject space separately
                ntractSkelInfo = fullfile(defn.outdir,tractFol,['SkelOverlap' defn.skelMethod{im} num2str(npiece) '.mat']);
                [cmeanFA{isubj,itr,idd,im},cweightFA{isubj,itr,idd,im},cmeanMD{isubj,itr,idd,im},cweightMD{isubj,itr,idd,im},cvoxperSeg{isubj,itr,idd,im},mfa,mmd,xyzfas,xyzmds] ...
                    = averageFAMDtractSkeletonOverlapReg(imFA,imMD,imfdt,ntractMask,ntractSkelInfo,subjname,defn);
                
                [a,b]=size(mfa);
                %  size: (ns,ntr,ndir,nskelMethod,npiece,nvox);
                matfa(isubj,itr,idd,im,1:a,1:b) = mfa; 
                matmd(isubj,itr,idd,im,1:a,1:b) = mmd; 
                [a,b,c]=size(xyzfas);
                xyzfa(isubj,itr,idd,im,1:a,1:b,1:c)= xyzfas;
                xyzmd(isubj,itr,idd,im,1:a,1:b,1:c)= xyzmds;
            end
        end
    end
end
toc

% save the results in mat files
dest = fullfile(defn.tractstatdir,['segment' num2str(npiece) '-thrFA' num2str(defn.thrFA) '-bval' defn.bval]);
mkdir(dest)
save(fullfile(dest,['alongTractDWI-' num2str(npiece) '.mat']),'cmeanFA','cmeanMD','cweightFA','cweightMD','cvoxperSeg','matfa','matmd','xyzfa','xyzmd')

% save the results in txt files
saveAlongTractMetricsTxt(cmeanFA,cmeanMD,cweightFA,cweightMD,subjs,npiece,defn)

% For plotting the results
defn.metric = {'Mean FA','Mean MD', 'Weighted FA', 'Weighted MD'};
% scale MD
cweightMD_sc=cellfun(@(x)(x*1000),cweightMD,'UniformOutput',0);
plotAlongTractMetrics(cweightFA,defn,'Weighted FA')
plotAlongTractPaper(cweightMD_mc,defn,'Weighted MD')
