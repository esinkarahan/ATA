function [weightMet,meanMet,xyzMet,matMet,numvox]=averagetract(imFA,imMD,imND,imODI,imfdtn,ntractMask,subjname,defn)
% FA & MD & NODDI values for the wole tract for single subject
% FA values are thresholded with thrFA and the same voxels are used for MD
% as well.
%
% INPUTS
% imFA           - 3D FA image
% imMD           - 3D MD image
% imND           - 3D NDI image
% imODI          - 3D ODI image
% imfdtn         - 3D tract volume that is registered to the DWI native space
% ntractMask     - Name of the label image 
% subjname       - cell array that contains the subject names
% defn           - structure that is defined in the setDefinition.m file
%
% Written by Esin Karahan, June, 2018
% 
% registration files
refVol     = fullfile(defn.dwidir,subjname,'nodif_brain');
refVolMask = fullfile(defn.dwidir,subjname,'nodif_brain_mask');

regTemp = 'regtemp.nii.gz';

if strcmp(defn.regMethod,'Linear')
    % linear registration
    matFile = fullfile(defn.trackdir,[subjname '.bedpostX'],'xfms','standard2diff.mat');
    system(sprintf('flirt -in %s -ref %s -out %s -init %s -applyxfm -interp nearestneighbour', ntractMask,refVol,regTemp, matFile));
else
    % nonlinear registration
    matFile = fullfile(defn.trackdir,[subjname '.bedpostX'],'xfms','standard2diff_warp');
    system(sprintf('applywarp --in=%s --ref=%s --out=%s --warp=%s --mask=%s --interp=nn', ntractMask,refVol,regTemp,matFile,refVolMask));
end

iRegMask=read_avw(regTemp);

% coordinates registered to dti native space
activeVoxelfa = (iRegMask>0) & (imFA>0) & (imfdtn>0);
% FA - calculate the probability
[weightMet(1),meanMet(1),xyzMet{1},matMet{1}] = calculateMean(imFA,imfdtn,iRegMask,activeVoxelfa,activeVoxelfa);
% repeat the same procedure for the other metrics
activeVoxelmd = (iRegMask>0) & (imMD>0) & (imfdtn>0);
[weightMet(2),meanMet(2),xyzMet{2},matMet{2}] = calculateMean(imMD,imfdtn,iRegMask,activeVoxelfa,activeVoxelmd);
activeVoxelnd = (iRegMask>0) & (imND>0) & (imfdtn>0);
[weightMet(3),meanMet(3),xyzMet{3},matMet{3}] = calculateMean(imND,imfdtn,iRegMask,activeVoxelfa,activeVoxelnd);
activeVoxelodi = (iRegMask>0) & (imODI>0) & (imfdtn>0);
[weightMet(4),meanMet(4),xyzMet{4},matMet{4}] = calculateMean(imODI,imfdtn,iRegMask,activeVoxelfa,activeVoxelodi);

numvox=sum(activeVoxelfa(:));
end
function [weightIm,meanIm,xyz,mat] = calculateMean(im,imfdtn,iRegMask,activeVoxel1,activeVoxel2)
% Calculate mean only over the nonzero voxels
weightIm = sum(sum(sum(im(activeVoxel1).*imfdtn(activeVoxel1)/sum(sum(sum(imfdtn(activeVoxel1)))))));
meanIm   = mean(im(activeVoxel2));

[a,b,c] = ind2sub(size(iRegMask),find(activeVoxel1));
xyz(1:length(a),1:3) = [a,b,c];
mat(1:length(a)) = squeeze(im(activeVoxel1));
end