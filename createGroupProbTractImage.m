function ref = createGroupProbTractImage(thr,subjs,tractFol,workdir,outdir,fslpath,atlasmask)
% Create group probabilistic map by thresholding the subject specific tractography maps
% with the specified value and unify them
% 
% ref = createGroupProbTractImage(thr,subjs,tractFol,workdir)
%
% Input:
% thr       - Treshold value to remove the spurious voxels in the probabilistic
%             tractography maps
% subjs     - A cell array that contains the subjects
% tractFol  - Name of the tractography folder after the subject name
% workdir   - Path of the tractography folder
% fslpath   - Path to call FSL functions for image manipulations
% atlasmask - (optional) Tract map from an atlas to mask the group map  
% 
% The tractographies should be stored as: workdir/subjName.tractFol/fdt_paths.nii.gz         
%
% Output:
% ref       - Probabilistic group mask image
%
% Written by Esin Karahan, November 2017
%

ns = length(subjs);

if length(thr) < ns
    display('It is assumed that the same threshold will be applied on each subject')
    thr = thr*ones(ns,1);
end

for is = 1:ns
	im  = fullfile(workdir,[subjs{is} '.' tractFol],'fdt_paths.nii.gz');
    out = fullfile(workdir,[subjs{is} '.' tractFol],'fdt_paths_thr_mask.nii.gz');
    system(sprintf('%s/fslmaths %s -thr %f -bin %s',fslpath,im,thr(is),out));
    if is == 1
        ref = fullfile(outdir,tractFol,'ANDmasksubjectsProb.nii.gz');
        copyfile(out,ref);
    else
        % AND operation
        system(sprintf('%s/fslmaths %s -add %s %s',fslpath,out,ref,ref)); 
    end
end
% create a probabilistic map
system(sprintf('%s/fslmaths %s -div %f %s',fslpath,ref,ns,ref));

if nargin > 5
    % multiply the group mask with the atlas tract not to include irrelevant
    % voxels
    system(sprintf('%s/fslmaths %s -mul %s %s',fslpath,ref,atlasmask,ref));
end