function writeLabelImageOverlap(vtractmask,assignMatSkel,assignInd,skelMethod,npiecetitle)
% Write ovelapping subvolumes as a separate image
% 
% INPUT
% vtractmask    - the header of the group mask image that is used for the
%                   skeletonization
% assignMatSkel - matrix for the assigned voxels to each piece (npieces x K)
% assignInd     - indices of the voxels that are assigned
% skelMethod    - matrix for label of each voxel (nvoxel x 2) 
% npiecetitle   - number of pieces
%
% Written by Esin Karahan, March, 2018
% 

dest   = fileparts(vtractmask.fname);
npiece = size(assignMatSkel,1);

for i=1:npiece
    Im  = zeros(vtractmask.dim);
    nz  = sum(assignMatSkel(i,:)>0); 
    if nz>1 %avoid empty segments
        sub = assignInd(assignMatSkel(i,1:nz),:);
        Im(sub2ind(vtractmask.dim,sub(:,1),sub(:,2),sub(:,3))) = 1;
        Vr = vtractmask;
        Vr.fname = fullfile(dest,['ANDmasksubjectsAssignMap' skelMethod num2str(npiecetitle) '-p' num2str(i) '.nii']);
        spm_write_vol(Vr,Im);
        gzip(Vr.fname)
        delete(Vr.fname)
    end
end
