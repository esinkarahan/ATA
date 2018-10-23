% Create probabilistic group image
%
% The tractographies should be stored as: workdir/subjName.tractName-tractLocation.probtrackX.Nonlinear.Stop/fdt_paths.nii.gz         
%
% Written by Esin Karahan, November 2017
%

for itr = 1:ntr
    for  idd = 1:ndir
        fprintf('Tract: %s Dir: %s \n',defn.tr{itr}, defn.dir{idd})
        
        tractFol  = [defn.tr{itr} '-' defn.dir{idd} '.probtrackX.Nonlinear.Stop'];
        atlasMask = fullfile(defn.trackdir,['mask/' defn.trm{itr}],['Juelich-' defn.trm{itr} '-' defn.dir{idd} '-prob-2mm']);
        mkdir(fullfile(defn.outdir,tractFol))

        if strcmp(defn.tr{itr},'OR-way'), a = 1; else a = 2; end
        if strcmp(defn.dir{idd},'L'),     b = 1; else b = 2; end
        
        nVoxSeed   = defn.nVoxSeedAll(a,b);

        thr_fdt = round(nVoxSeed * defn.nSamples * defn.thrSet);
        thr_fdt = thr_fdt*ones(ns,1);

        groupMask=createGroupProbTractImage(thr_fdt,subjs,tractFol,defn.trackdir,defn.outdir,fslpath,atlasMask);
    end
end
