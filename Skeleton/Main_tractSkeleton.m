% Finds the skeleton of volumetric tracts
%
% Esin Karahan, Jan 2018
%
% ATTENTION! DIKKAT!
% If skeleton is already created, for trimming the volume and sampling the
% skeleton
% use the script 'resampleSkeleton.m' in this directory
%

clear
close all

run('setDirectory.m')
run('setDefinition.m')

% if you want to save the final skeleton
writeSkelLine  = 1;

% write the labeled tract volume as an image. 
writeLabelVolFlag    = 0;

if ~exist('npiece')
    npiece = 30;
end

for itr = 1:ntr
    for  idd = 1:ndir
        
        fprintf('Tract: %s Dir: %s Met: %s \n', defn.tr{itr}, defn.dir{idd}, defn.regMethod)
        
        tractFol=[defn.tr{itr} '-' defn.dir{idd} '.probtrackX.' defn.regMethod '.Stop'];
        ntractmask=fullfile(defn.outdir,tractFol,'ANDmasksubjectsProb.nii.gz');
        
        % 1 - load the mask and binarize if not
        vtractmask = spm_vol(ntractmask);
        imask = spm_read_vols(vtractmask);
        imask(imask>0)=1;
        
        % 2 - remove the outlier voxels
        imaskr = removeVoxel(imask,'some',100,2);
        
        % Fill the holes if any by first smoothing then eroding
        % This is good for OR but not CST
        if strcmp(defn.trm{itr},'OR')
            W1 = imaskr;
            SE = strel('disk',1);
            imaskrs = imdilate(W1,SE);
            imaskrs(imaskrs>0)= 1;
            visualizeObject({imaskr,imaskrs}), title('After dilation')
            W1 = imaskrs; 
        else
            W1=imaskr;
        end
        
        % 3 - Find the skeleton
        %%% VSK toolbox
        EL=15;AZ=-120;
        [rows, cols, slices] = size(imaskr);
        [X,Y,Z] = meshgrid(1:cols, 1:rows, 1:slices);
        rev=0; show = W1; vol = W1;
        
        % Find the skeleton by using distance method
        [skel_dist,Tdist] = skel_Distmethod_mod(vol, show, rows, cols, slices, X, Y, Z, AZ, EL, 0,0,1,[]);
        
        % Find the skeleton by using thinning Method
        % As a rule of thumb, I did not prefer to use the internal pruning
        % tool of this function, since it happened to prune randomly. I used
        % my own pruning function which is basically removing the nodes
        % with only 1 neighbor sequentially
        [skel_thin,Tthin] = skel_thinningmethod_mod(vol, show, rows, cols, slices, X, Y, Z, AZ, EL, rev);
        
        % 4 - prune the single branches on the skeleton
        [Tdistprun,skel_dist_prun] = pruneBranchSkel(vol,Tdist,skel_dist,'loop');
        visualizeObjectSkel(vol,skel_dist_prun,Tdistprun)
        [Tthinprun,skel_thin_prun] = pruneBranchSkel(vol,Tthin,skel_thin,'loop');
        visualizeObjectSkel(vol,skel_thin_prun,Tthinprun)
        
        % Organize the skeleton so that successive points are connected to each other
        [Tdistprunr,skel_dist_prunr] = organizeSkelLine(Tdistprun,skel_dist_prun);
        [Tthinprunr,skel_thin_prunr] = organizeSkelLine(Tthinprun,skel_thin_prun);
        
        % 5 - interpolate the skeleton
        nSampleInterp = 1200;
        [skel_dist_prun_interp,T1] = spline3dCurveInterpolation(skel_dist_prunr, nSampleInterp);
        [skel_thin_prun_interp,T2] = spline3dCurveInterpolation(skel_thin_prunr, nSampleInterp);

        % 5.0 prune the skeleton so that it will not lay outside of the image
        [skel_dist_prun_interp,in] = limitSkelwithImage(skel_dist_prun_interp,vol);
        T1 = T1(in,in);
        visualizeObjectSkel(vol,skel_dist_prun_interp);
        print(fullfile(defn.outdir,tractFol,[defn.trm{itr} '-' defn.dir{idd} '-skel-dist']),'-dpng')

        [skel_thin_prun_interp,in] = limitSkelwithImage(skel_thin_prun_interp,vol);
        T2 = T2(in,in);
        visualizeObjectSkel(vol,skel_thin_prun_interp);
        print(fullfile(defn.outdir,tractFol,[defn.trm{itr} '-' defn.dir{idd} '-skel-thin']),'-dpng')

        
        % 5.1 save the skeleton
        if writeSkelLine
            skel = skel_dist_prun_interp; T=T1;
            save(fullfile(defn.outdir,tractFol,'skel_Dist.mat'),'skel','T','imaskr')
            skel = skel_thin_prun_interp; T=T2;
            save(fullfile(defn.outdir,tractFol,'skel_Thin.mat'),'skel','T','imaskr')
        end
    end
end