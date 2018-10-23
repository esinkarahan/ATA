% Find the significant statistics from the results of the TFCE analysis
% positive-negative stats are separate
%
% Stat files are saved as mat files
%
% At the end of the script T values of the segments are plotted and saved.
% In the figures:
% asteriks     - significant uncorrected pval
% red clubsuit - significant corrected p val
% green bullet - significant cluster corrected p val
%
% Positive and negative contrast are tested separately
%
% Written by Esin Karahan, May, 2018
%

% These variables are saved
tstat   = zeros(ndti,ntr,ndir,npiece,nbehav-1,2)*NaN;
pval    = zeros(ndti,ntr,ndir,npiece,nbehav-1,2)*NaN;
fwevalcluster = zeros(ndti,ntr,ndir,npiece,nbehav-1,2)*NaN;
fdr     = zeros(ndti,ntr,ndir,npiece,nbehav-1,2)*NaN;
cope    = zeros(ndti,ntr,ndir,npiece,nbehav-1,2)*NaN;

thrfweclus=0.05; thruncor=0.05;
ext = '.csv';
stat_type = 'dat';

for idt = 1:ndti
    outdir = fullfile(defn.statdir,['minVox' num2str(defn.minVoxSeg)],defn.bval,[defn.dti{idt} '-' defn.bval]);
    for itr = 1:ntr
        for  idd = 1:ndir
            for icon = 1:ncon
                for ic = 1:2 %positive-negative
                    outFileFdr = fullfile(outdir,[defn.tr{itr} '-' defn.dir{idd} ...
                        '-' num2str(npiece) '-' defn.con{icon} defn.addsmooth '_' stat_type '_tstat_fdrp_c' num2str(ic) ext]);
                    outFileFwe = fullfile(outdir,[defn.tr{itr} '-' defn.dir{idd} ...
                        '-' num2str(npiece) '-' defn.con{icon} defn.addsmooth '_' stat_type '_tstat_fwep_c' num2str(ic) ext]);
                    outFileUnc = fullfile(outdir,[defn.tr{itr} '-' defn.dir{idd} ...
                        '-' num2str(npiece) '-' defn.con{icon} defn.addsmooth '_' stat_type '_tstat_uncp_c' num2str(ic) ext]);
                    outFileTstat = fullfile(outdir,[defn.tr{itr} '-' defn.dir{idd} ...
                        '-' num2str(npiece) '-' defn.con{icon} defn.addsmooth '_' stat_type '_tstat_c' num2str(ic) ext]);
                    if strcmp(ext,'.nii.gz')
                        outFileCope = fullfile(outdir,[defn.tr{itr} '-' defn.dir{idd} ...
                        '-' num2str(npiece) '-' defn.con{icon} defn.addsmooth '_vox_cope_c' num2str(ic) ext]);
                    else %csv, each point is data not voxel
                        outFileCope = fullfile(outdir,[defn.tr{itr} '-' defn.dir{idd} ...
                        '-' num2str(npiece) '-' defn.con{icon} defn.addsmooth '_dat_cope_c' num2str(ic) ext]);
                    end
                    if strcmp(ext,'.nii.gz')
                        if ispc
                            tf = loadImageSpm(outFileFwe);
                            tfd= loadImageSpm(outFileFdr);
                            tu = loadImageSpm(outFileUnc);
                            tt = loadImageSpm(outFileTstat);
                            tb = loadImageSpm(outFileCope);
                        else
                            tf = read_avw(outFileFwe);
                            tfd= read_avw(outFileFdr);
                            tu = read_avw(outFileUnc);
                            tt = read_avw(outFileTstat);
                            tb = read_avw(outFileCope);
                        end
                    else
                        tf = load(outFileFwe);
                        tfd= load(outFileFdr);
                        tu = load(outFileUnc);
                        tt = load(outFileTstat);
                        tb = load(outFileCope);
                    end
                    ntest=max(size(tf));
                    fwevalcluster(idt,itr,idd,1:ntest,icon,ic) = tf(:);
                    fdr(idt,itr,idd,1:ntest,icon,ic)  = tfd(:);
                    pval(idt,itr,idd,1:ntest,icon,ic) = tu(:);
                    tstat(idt,itr,idd,1:ntest,icon,ic)= tt(:);
                    cope(idt,itr,idd,1:ntest,icon,ic)= tb(:);
                end
            end
        end
    end
end
save(fullfile(defn.statdir,['minVox' num2str(defn.minVoxSeg)],bval_fa,['stat-' defn.noddi '-' defn.addsmooth '-' num2str(npiece) '-' bval_fa '-' defn.con{1} '-' stat_type '.mat']),'fwevalcluster','fdr','pval','tstat','cope');
if sum(strcmp(defn.con,'rs_age')) %Raven score
    behavSel = 1;
else % RT, T0
    behavSel = [1 2];
end
%positive contrast
% mean behavSel,dtiSel
plotRegTract(pval(:,:,:,:,:,1),fdr(:,:,:,:,:,1),fwevalcluster(:,:,:,:,:,1),...
    tstat(:,:,:,:,:,1),thruncor,behavSel,[1 2],defn,npiece,['pos-' bval_fa '-'  defn.con{1} '-' stat_type])
% weighted
plotRegTract(pval(:,:,:,:,:,1),fdr(:,:,:,:,:,1),fwevalcluster(:,:,:,:,:,1),...
    tstat(:,:,:,:,:,1),thruncor,behavSel,[3 4],defn,npiece,['pos-' bval_fa '-' defn.con{1} '-' stat_type])
%negative contrast
% mean
plotRegTract(pval(:,:,:,:,:,2),fdr(:,:,:,:,:,2),fwevalcluster(:,:,:,:,:,2),...
    tstat(:,:,:,:,:,2),thruncor,behavSel,[1 2],defn,npiece,['neg-' bval_fa '-' defn.con{1} '-' stat_type])
% weighted
plotRegTract(pval(:,:,:,:,:,2),fdr(:,:,:,:,:,2),fwevalcluster(:,:,:,:,:,2),...
    tstat(:,:,:,:,:,2),thruncor,behavSel,[3 4],defn,npiece,['neg-' bval_fa '-' defn.con{1} '-' stat_type])

