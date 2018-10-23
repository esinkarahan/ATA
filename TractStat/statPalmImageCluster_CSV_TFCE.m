% Script for applying multiple comparison on the along stat metrics of DTI
% and NODDI metrics
% PALM toolbox from FSL is used for statistical analysis. Multiple
% comparison is corrected with TFCE. 
% TFCE stats on csv tables - when they are treated as images
% 
% Note that the Design Matrix and contrast should be prepared before the
% statistical analysis bu using the Glm function of fsl. 
% The design file in this script is in
% designdir = fullfile(defn.statdir,['design_' defn.con{icon}]);
%
% Written by Esin Karahan, May, 2018
%
jm = 1; % use one skeletonization method

% In case there are any outlier subjects
if defn.minVoxSeg == 10
%these were the unsorted subjects.
    outlierSubj=[3 33];
else
    outlierSubj = [];
end
if ~isempty(outlierSubj)
    % we need to sort
    [subjsort,fslsort] = sort(subjs);
    outlierSubjsort(1) = find(fslsort==outlierSubj(1));
    outlierSubjsort(2) = find(fslsort==outlierSubj(2));
else
    outlierSubjsort = [];
end

% In case other parameters are wanted to be compared
if sum(strcmp(defn.con,'rs_age')) %Raven score
   % load raven's data - less subjects (35 of 46 subjects have IQ scores)
    load(fullfile(defn.behavdir,'RavenScoreAgefslsort.mat')) % Score,Age
    outlierSubjsort = find(logical(not(subjectsIn_sc)));
end

selectedSubj = setdiff(1:ns,outlierSubjsort);
nsnew        = length(selectedSubj);

for idt = 1:ndti
    outdir = fullfile(defn.statdir,['minVox' num2str(defn.minVoxSeg)],defn.bval,[defn.dti{idt} '-' defn.bval]);
    mkdir(outdir)
    for itr = 1:ntr
        for  idd = 1:ndir
            tractFol = [defn.tr{itr} '-' defn.dir{idd} '.probtrackX.' defn.regMethod '.Stop'];
            tractName= [defn.tr{itr} '-' defn.dir{idd}];
            
            %%% load the DTI measures
            % already sorted.
            metricDir = fullfile(defn.tractstatdir,['segment' num2str(npiece) '-thrFA' num2str(defn.thrFA) '-bval' defn.bval]);
            mFA = load(fullfile(metricDir,['alongTract' defn.dti{idt} 'minv' num2str(defn.minVoxSeg) '.txt']));
            % remove subjects
            mFA = mFA(:,selectedSubj);
            
            %remove the NaNs and zeros on FA
            set = sum((~isnan(mFA)) & (mFA~=0),2);
            %add the pieces with less than ns subjects to the ignorance
            %columns
            rnonans = (set==nsnew);
            mFAclean = (mFA(rnonans,:))';            
            ntest = size(mFAclean,2);

            if strcmp(defn.addsmooth,'smooth')
                % moving average filter
                if isfield(defn,'parsmooth')
                    parMa = defn.parsmooth;
                else
                    parMa = 3; %moving average parameter
                end
                mFAclean = mafilt1(mFAclean',parMa);
                mFAclean = mFAclean';
            end
           % write group table for each case 
           % note that the subset of the subjects are picked from raven's
           % score contrast
            T = array2table(mFAclean);
            groupIm = sprintf('%s/group%s_%s_%s_%s.csv',outdir,defn.dti{idt},tractName,num2str(npiece),defn.addsmooth);
            writetable(T,groupIm,'WriteVariableNames',0);

            % FWE, FDR tests based on the TFCE 
            for icon = 1:ncon
                designdir = fullfile(defn.statdir,['design_' defn.con{icon}]);
                outFile = fullfile(outdir,[defn.tr{itr} '-' defn.dir{idd} '-' num2str(npiece) '-' defn.con{icon} defn.addsmooth]);
                % Mean center the data and the columns of the design
                % matrix, TFCE stats, FWER and FDR corrected separately 
                eval(sprintf('palm -i %s -o %s -d %s -t %s -n 5000 -tableasvolume -noniiclass -demean -tfce1D -T -fdr -quiet -saveglm',groupIm,outFile,fullfile(designdir,'design.mat'),fullfile(designdir,'design.con')));
            end
        end
    end
end

