function [meanFA,weightFA,meanMD,weightMD,voxperSeg,matfa,matmd,xyzfa,xyzmd]=averageFAMDtractSkeletonOverlapReg(imFA,imMD,imfdtn,ntractMask,ntractSkelInfo,subjname,defn)
%
% FA & MD values along the tract for single subject
% The regions are delienated in ntractmask
% FA values are thresholded with thrFA and the same voxels are used for MD
% as well.
%
% subvolumes are overlapping
% each subvolume is registered with flirt interp option
% INPUTS
% imFA           - 3D FA image
% imMD           - 3D MD image
% imfdtn         - 3D tract volume that is registered to the DWI native space
% ntractMask     - Name of the label image 
% ntractSkelInfo - Skeleton structure  
% subjname       - cell array that contains the subject names
% defn           - structure that is defined in the setDefinition.m file
% 
% Written by Esin Karahan, February, 2018
%

load(ntractSkelInfo);
nPiece = size(assignMatSkel,1);

meanFA   = zeros((nPiece),1)*NaN;
weightFA = zeros((nPiece),1)*NaN;
meanMD   = zeros((nPiece),1)*NaN;
weightMD = zeros((nPiece),1)*NaN;

% registration files
refVol     = fullfile(defn.dwidir,subjname,'nodif_brain');
refVolMask = fullfile(defn.dwidir,subjname,'nodif_brain_mask');

regTemp = 'regtemp.nii.gz';

[path,name]=fileparts(ntractMask);

voxperSeg = zeros(nPiece,1);
for ip = 1:nPiece
    % volume mask
    % register each subvolume to the native space
    ntractpiecemask = fullfile(path,[name '-p' num2str(ip) '.nii.gz']);
    
    if strcmp(defn.regMethod,'Linear')
        % linear registration
        matFile = fullfile(defn.trackdir,[subjname '.bedpostX'],'xfms','standard2diff.mat');
        system(sprintf('%s/flirt -in %s -ref %s -out %s -init %s -applyxfm -interp nearestneighbour', defn.fsldir, ntractpiecemask,refVol,regTemp, matFile));
    else
        % nonlinear registration
        matFile = fullfile(defn.trackdir,[subjname '.bedpostX'],'xfms','standard2diff_warp');
        system(sprintf('%s/applywarp --in=%s --ref=%s --out=%s --warp=%s --mask=%s --interp=nn', defn.fsldir, ntractpiecemask,refVol,regTemp,matFile,refVolMask));
    end
    
    iRegMask=read_avw(regTemp);

    % coordinates registered to dti native space
    activeVoxelfa = (iRegMask>0) & (imFA>0) & (imfdtn>0);
    
    % FA - calculate the probability
    weightFA(ip) = sum(sum(sum(imFA(activeVoxelfa).*imfdtn(activeVoxelfa)/sum(sum(sum(imfdtn(activeVoxelfa)))))));
    meanFA(ip)   = mean(imFA(activeVoxelfa));

    [a,b,c] = ind2sub(size(iRegMask),find(activeVoxelfa));
    xyzfa(ip,1:length(a),1:3) = [a,b,c];
    matfa(ip,1:length(a)) = squeeze(imFA(activeVoxelfa));

    %MD - calculate the probability
    activeVoxelmd = (iRegMask>0) & (imMD>0) & (imfdtn>0);
    weightMD(ip)  = sum(sum(sum(imMD(activeVoxelfa).*imfdtn(activeVoxelfa)/sum(sum(sum(imfdtn(activeVoxelfa)))))));
    meanMD(ip)    = mean(imMD(activeVoxelmd));

    [a,b,c] = ind2sub(size(iRegMask),find(activeVoxelmd));
    xyzmd(ip,1:length(a),1:3) = [a,b,c];
    matmd(ip,1:length(a)) = squeeze(imMD(activeVoxelmd));
    
    voxperSeg(ip)=sum(activeVoxelfa(:));
end
meanFA(meanFA==0) = NaN;
meanMD(meanMD==0) = NaN;
weightFA(weightFA==0) = NaN;
weightMD(weightMD==0) = NaN;
