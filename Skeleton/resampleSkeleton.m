% Trims the tract volumes and the skeleton calculated in the previous step
% Labels the tract volume to ovelapping OR uniform skeletons
%
% Written by Esin Karahan, Feb 2018
%

clear
close all

run('setDirectory.m')
run('setDefinition.m')

% save the cropped group mask image
writeTractVol = 1;

% save the cropped skeleton as a 3D line
writeSkelLine = 1;
% create overlapping segments in a skeleton. This will create a mat file
% and also seperate label images for each segment. This label image cannot
% be saved as a single image since some voxels may have been assigned to more than 1
% segment.
overlapFlag  = 1;

% write the labeled tract volume as an image. (uniform labeling)
writeLabelVolFlag = 1;

% write skeleton as a volume
writeSkelVol  = 0;

npiece = 30;

if npiece==50
    overlapRatio = 0.5;
elseif npiece==40
    overlapRatio = 0.5;
elseif npiece==20
    overlapRatio = 0.2;
elseif npiece==30
    overlapRatio = 0.2;
end

for isk = 1:nskelMethod
    for itr = 1:ntr
        for  idd = 1:ndir
            fprintf('Tract: %s Dir: %s Met: %s \n', defn.tr{itr}, defn.dir{idd})
            
            tractFol=[defn.tr{itr} '-' defn.dir{idd} '.probtrackX.' defn.regMethod '.Stop'];
            ntractmask=fullfile(defn.outdir,tractFol,'ANDmasksubjectsProb.nii.gz');
            vtractmask = spm_vol(ntractmask);
            
            % load the skeleton
            load(fullfile(defn.outdir,tractFol,['skel_' defn.skelMethod{isk} '.mat']),'skel','imaskr')
            vol = imaskr;
            clear imaskr
            
            % trim the volume and the skeleton
            if strcmp(defn.trm{itr},'CST')
                % first retrieve the borders
                borderRoi = bordersWayPointROI_CST(defn);
                % use round due to oversampling in the skel space
                keepCoord = (floor(skel(:,3)) >= borderRoi{idd}(1,3))...
                    &(floor(skel(:,3))<= borderRoi{idd}(2,3));
                % remove the coordinates that lay outside of the borders
                skel = skel(keepCoord,:);
                
                % do the same on the volume!
                nz = size(vol,3);
                vol(:,:,((1:nz) < borderRoi{idd}(1,3)) | ((1:nz) > borderRoi{idd}(2,3)) ) = 0;
                % check whether it is ok
                visualizeObjectSkel(vol,skel);
            end
            if strcmp(defn.trm{itr},'OR')
                % Remove from V1
                borderPosterior = 21;
                % NEW: added in 21/08/2018
                % Remove from LGN
                borderAnterior = 53;
                % use round due to oversampling in the skel space
                keepCoord = (floor(skel(:,2)) >= borderPosterior) & (floor(skel(:,2)) < borderAnterior-4);
                % remove the coordinates that lay outside of the borders
                skel = skel(keepCoord,:);
                
                % do the same on the volume!
                ny = size(vol,2);
                vol(:,((1:ny) < borderPosterior) | ((1:ny) >= borderAnterior) ,:) = 0;
                % check whether it is ok
                visualizeObjectSkel(vol,skel);
            end
            
            % prune the skeleton so that it will not lay outside of the image
            skel = limitSkelwithImage(skel,vol);
            visualizeObjectSkel(vol,skel);
            
            nskel = size(skel,1);
            if mod(nskel,npiece)
                % upsample
                nskelnew = ceil(nskel/npiece)*npiece;
                % interpolate
                skel = spline3dCurveInterpolation(skel, nskelnew);
            end
            
            if writeSkelLine
                save(fullfile(defn.outdir,tractFol,['skel_' defn.skelMethod{isk}  '_crop.mat']),'skel')
            end
            
            % allow pieces to have overlapping areas
            % save each segment of the tract volume
            if overlapFlag
                skeloverlap = divideSkelOverlap(skel,npiece,overlapRatio);
                [assignMat,assignInd,assignMatSkel] = assignVoxel2SkeletonOverlap(vol,skeloverlap);
                writeLabelImageOverlap(vtractmask,assignMatSkel,assignInd,defn.skelMethod{isk},npiece);
                save(fullfile(defn.outdir,tractFol,['SkelOverlap' defn.skelMethod{isk} num2str(npiece) '.mat']), 'skeloverlap','assignMat', 'assignInd', 'assignMatSkel');
            end
            
            % divide the skeleton into equal pieces
            skeluni = divideSkel(skel,npiece);
            % Assign the voxels in the volume to the skeleton that is
            % uniformly divided
            if writeLabelVolFlag
                assignMap = assignVoxel2Skeleton(vol,skeluni);
                V = vtractmask;
                V.fname=fullfile(defn.outdir,tractFol,['ANDmasksubjectsAssignMap' defn.skelMethod{isk} num2str(npiece) '.nii']);
                spm_write_vol(V,assignMap);
                gzip(V.fname)
                delete(V.fname)
            end
            
            % Save skeleton as an image
            if writeSkelVol
                V = vtractmask;
                V.fname = fullfile(matdir,tractFol,['SkelVolume' defn.skelMethod{isk} num2str(npiece) '.nii']);
                [skelVolThin,xyz] = skeleton2volume(skel,size(vol),V);
                save(fullfile(defn.outdir,tractFol,['Skel' defn.skelMethod{isk} 'xyz' num2str(npiece) '.mat']),'xyz');
            end
            
            % Save the cropped tract image as well
            if writeTractVol
                V = vtractmask;
                V.fname=fullfile(defn.outdir,tractFol,'ANDmasksubjectsProbCropBin.nii');
                spm_write_vol(V,vol);
                gzip(V.fname)
                delete(V.fname)
            end
        end
    end
end
