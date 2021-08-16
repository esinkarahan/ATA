% save definitions 
defn.tractName = {'Optic Radiation', 'Corticospinal Tract'};
defn.tr  = {'OR-way','CST'};
defn.trm = {'OR','CST'};
defn.dir = {'L','R'};
defn.skelMethod = {'Thin'}; 
defn.regMethod  = 'Nonlinear';
defn.dti        = {'meanFA','meanMD','weightFA','weightMD'};
defn.con        = {'rt_age','t0_age'};
defn.behav      = {'RT','T0','Age'};
defn.sign       = {'positive','negative'};
defn.minVoxSeg  = 2;  %we expect each subject have at least 2 voxels in each segment
defn.thrFA      = 0.2;

% directories
defn.behavdir   = fullfile(datadir,'behavParam');
defn.dwidir     = fullfile(datadir,'dti');
defn.trackdir   = fullfile(datadir,'probtrackx');
defn.noddidir   = fullfile(datadir,'noddi');
defn.fsldir     = fslpath;

% thresholding the tracts
defn.nSamples = 5000;
% include all the voxels that received at least the 5x10^(-5) of the
% total streamlines sent out from the ROI masks used to trace that tract
defn.thrSet   = 5E-5;
% # of voxels in each seed mask
% fslstats LGN-L -V
% [165 145]; % L - R
% fslstats Cerebral-Peduncle-L -V
% [263 268]; % L - R
defn.nVoxSeedAll = [165 145; 263 268];

% thresholding value of FA
defn.thrFA = 0.2;
defn.bval  = '1200';
% number of pieces in the skeleton
defn.npiece = 30;

subjs  = readSubjectsFromFile(fullfile(datadir,'subjectList.txt'));
ns     = length(subjs);
ntr    = length(defn.tr);
ndir   = length(defn.dir);
nbehav = length(defn.behav);
ndti   = length(defn.dti);
ncon   = length(defn.con); 
nskelMethod = length(defn.skelMethod);

% directory for the results
defn.statdir = fullfile(outdir,'stats');
defn.tractstatdir = fullfile(outdir,'tractStatResults',defn.regMethod);
defn.outdir  = outdir;
