function rnonans = findIgnoranceColumns(defn,idt,tractFol,maindir)

if defn.minVoxSeg == 10 %note:this cannot be together with raven's score contrast
%these were the unsorted subjects.
    outlierSubj=[3 33];
else
    outlierSubj = [];
end
subjs  = readSubjectsFromFile(fullfile(maindir,'subjectList.txt'));
ns = length(subjs);
if ~isempty(outlierSubj)
    % we need to sort
    [subjsort,fslsort] = sort(subjs);
    outlierSubjsort(1) = find(fslsort==outlierSubj(1));
    outlierSubjsort(2) = find(fslsort==outlierSubj(2));
else
    outlierSubjsort = [];
end

if sum(strcmp(defn.con,'rs_age')) %Raven score
   % load raven's data - less subjects (35 of 46 subjects have IQ scores)
    load(fullfile(defn.behavdir,'RavenScoreAgefslsort.mat')) % Score,Age
    outlierSubjsort = find(logical(not(subjectsIn_sc)));
end

selectedSubj=setdiff(1:ns,outlierSubjsort);
nsnew = length(selectedSubj);

mFA = load(fullfile(defn.destdir,tractFol,['alongTract' defn.dti{idt} 'minv' num2str(defn.minVoxSeg) '.txt']));
% remove subjects
mFA = mFA(:,selectedSubj);
%remove the NaNs and zeros on FA
set = sum((~isnan(mFA)) & (mFA~=0),2);
%add the pieces with less than ns subjects to the ignorance
%columns
rnonans = (set==nsnew);
