function [cmeanFA,cmeanMD,cweightFA,cweightMD,coeff,nanList] = plotAlongTract(cmeanFA,cmeanMD,cweightFA,cweightMD,cvoxperSeg,subjs,npiece,applyMaFilter,parMa,defn)
% 
% Plot the results along the tract and save the results
% 
% Written by Esin Karahan, February, 2018
%

[ns,ntr,ndir,nskelMethod]=size(cmeanFA);
coeff = zeros(ntr,ndir,nskelMethod);
ck=1;
nanList=0;
[~,fslsort]=sort(subjs);
for itr = 1:ntr
    for idd = 1:ndir
        tractFol   = [defn.tr{itr} '-' defn.dir{idd} '.probtrackX.' defn.regMethod '.Stop'];
        mkdir(fullfile(defn.destdir,tractFol))
        for im = 1:nskelMethod
            for isubj=1:ns
                if sum(isnan(cmeanFA{isubj,itr,idd,im}))>0
                    incident = sum(isnan(cmeanFA{isubj,itr,idd,im}));
                    nanList(ck,1:5)=[isubj,itr,idd,im,incident];
                    ck=ck+1;
                end
            %  % interpolate dti measures
                if applyMaFilter
                    % moving average filter
                    cmeanFA{isubj,itr,idd,im}   = mafilt1(cmeanFA{isubj,itr,idd,im},parMa);
                    cmeanMD{isubj,itr,idd,im}   = mafilt1(cmeanMD{isubj,itr,idd,im},parMa);
                    cweightFA{isubj,itr,idd,im} = mafilt1(cweightFA{isubj,itr,idd,im},parMa);
                    cweightMD{isubj,itr,idd,im} = mafilt1(cweightMD{isubj,itr,idd,im},parMa);
                end
            end
            fileTitle = [defn.tr{itr} '-' defn.dir{idd} '-' defn.skelMethod{im}  '-' num2str(npiece)];
            
            nPiece = length(cmeanMD{1,itr,idd,im});
            meanFA = reshape(cell2mat(cmeanFA(:,itr,idd,im)),nPiece,ns);
            meanMD = reshape(cell2mat(cmeanMD(:,itr,idd,im)),nPiece,ns);
            weightFA = reshape(cell2mat(cweightFA(:,itr,idd,im)),nPiece,ns);
            weightMD = reshape(cell2mat(cweightMD(:,itr,idd,im)),nPiece,ns);
            
            meanFA(meanFA==0) = NaN;
            meanMD(meanMD==0) = NaN;
            weightFA(weightFA==0) = NaN;
            weightMD(weightMD==0) = NaN;

            
            x = 1:nPiece;
            figure,
            subplot(2,2,1),shadedErrorBar(x,meanFA',{@takemeanNan,@takestdNan}),title([defn.dti{1} ' ' defn.tr{itr} '-' defn.dir{idd} '-' defn.skelMethod{im} '-' num2str(npiece)]),axis tight 
            subplot(2,2,2),shadedErrorBar(x,meanMD',{@takemeanNan,@takestdNan}),title([defn.dti{2} ' ' defn.tr{itr} '-' defn.dir{idd} '-' defn.skelMethod{im} '-' num2str(npiece)]), axis tight
            subplot(2,2,3),shadedErrorBar(x,weightFA',{@takemeanNan,@takestdNan}),title([defn.dti{3} ' ' defn.tr{itr} '-' defn.dir{idd} '-' defn.skelMethod{im} '-' num2str(npiece)]), axis tight
            subplot(2,2,4),shadedErrorBar(x,weightMD',{@takemeanNan,@takestdNan}),title([defn.dti{4} ' ' defn.tr{itr} '-' defn.dir{idd} '-' defn.skelMethod{im} '-' num2str(npiece)]), axis tight
            
            tractFol   = [defn.tr{itr} '-' defn.dir{idd} '.probtrackX.' defn.regMethod '.Stop'];
            print(fullfile(defn.destdir,['alongTract' defn.dti{1} '-' fileTitle]),'-dpng')
            
            voxCount=reshape(cell2mat(cvoxperSeg(:,itr,idd,im)),nPiece,ns)';
            nanSegment = find(sum(voxCount==0));
            figure,
            bar(x,mean(voxCount)),title(['Mean voxel per segment ' fileTitle]), axis tight
            text(nanSegment,mean(voxCount(:,nanSegment))+1,'*')
            
            print(fullfile(defn.destdir,['voxperSegment-' fileTitle]),'-dpng')
            
            % sorting & mean correcting
            meanFAsort=meanFA(:,fslsort);
            meanFAsortmc=meanFAsort-repmat(takemeanNan(meanFAsort,2),[1 ns]);
            meanMDsort=meanMD(:,fslsort);
            meanMDsortmc=meanMDsort-repmat(takemeanNan(meanMDsort,2),[1 ns]);
            
            weightFAsort=weightFA(:,fslsort);
            weightFAsortmc=weightFAsort-repmat(takemeanNan(weightFAsort,2),[1 ns]);
            weightMDsort=weightMD(:,fslsort);
            weightMDsortmc=weightMDsort-repmat(takemeanNan(weightMDsort,2),[1 ns]);
            
            save(fullfile(defn.destdir,tractFol,['alongTract' defn.dti{1} '.txt']),'meanFAsortmc','-ascii')
            save(fullfile(defn.destdir,tractFol,['alongTract' defn.dti{2} '.txt']),'meanMDsortmc','-ascii')
            save(fullfile(defn.destdir,tractFol,['alongTract' defn.dti{3} '.txt']),'weightFAsortmc','-ascii')
            save(fullfile(defn.destdir,tractFol,['alongTract' defn.dti{4} '.txt']),'weightMDsortmc','-ascii')
            
            %calculate the correlation between MD and FA to see whether
            %everything is ok
            nanreg = (sum(isnan(meanFA),2)==ns);
            if sum(nanreg)<size(meanFA,1)
                coeff(itr,idd,im) = (corr(takemeanNan(meanFA(~nanreg,:)')',takemeanNan(meanMD(~nanreg,:)')'));
            end
        end
    end
end

% figure,bar(reshape(cell2mat(cvoxperSeg(:,1,1,1)),[],ns)),axis tight %CST-L-dist
% figure,bar(reshape(cell2mat(cvoxperSeg(:,1,1,2)),49,ns))
