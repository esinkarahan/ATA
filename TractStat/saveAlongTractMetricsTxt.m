function [] = saveAlongTractMetricsTxt(cmeanFA,cmeanMD,cweightFA,cweightMD,subjs,npiece,defn)
% 
% Save the along tract metrics as txt files to do statistical analysis
% Subjects are sorted
%
% Written by Esin Karahan, February, 2018
%

[ns,ntr,ndir,nskelMethod]=size(cmeanFA);
[~,fslsort]=sort(subjs);
for itr = 1:ntr
    for idd = 1:ndir
        tractFol   = [defn.tr{itr} '-' defn.dir{idd} '.probtrackX.' defn.regMethod '.Stop'];
        for im = 1:nskelMethod
            destdir = fullfile(defn.tractstatdir,['segment' num2str(npiece) '-thrFA' num2str(defn.thrFA) '-bval' defn.bval]);
            npreal  = length(cweightMD{1,itr,idd,im});
            % mean measures
            meanFA = reshape(cell2mat(cmeanFA(:,itr,idd,im)),npreal,ns);
            meanMD = reshape(cell2mat(cmeanMD(:,itr,idd,im)),npreal,ns);
            meanFA = meanFA(:,fslsort);
            meanMD = meanMD(:,fslsort);
            meanFAsort = meanFA(:,fslsort);
            meanMDsort = meanMD(:,fslsort);
            save(fullfile(destdir,['alongTract' defn.dti{1} 'minv' num2str(defn.minVoxSeg) '.txt']),'meanFAsort','-ascii')
            save(fullfile(destdir,['alongTract' defn.dti{2} 'minv' num2str(defn.minVoxSeg) '.txt']),'meanMDsort','-ascii')
            
            % weighted measures
            weightFA = reshape(cell2mat(cweightFA(:,itr,idd,im)),npreal,ns);
            weightMD = reshape(cell2mat(cweightMD(:,itr,idd,im)),npreal,ns);
            weightFAsort=weightFA(:,fslsort);
            weightMDsort=weightMD(:,fslsort);
            save(fullfile(destdir,['alongTract' defn.dti{3} 'minv' num2str(defn.minVoxSeg) '.txt']),'weightFAsort','-ascii')
            save(fullfile(destdir,['alongTract' defn.dti{4} 'minv' num2str(defn.minVoxSeg) '.txt']),'weightMDsort','-ascii')
            
        end
    end
end
