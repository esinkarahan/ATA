function plotRegTract(pval,corrpval,corrpvalcluster,rho,pthr,behavSel,dtiSel,defn,piece,varargin)
% plot the stats (rho variable) with the significancy value
% asteriks     - significant uncorrected pval
% red clubsuit - significant corrected p val
% green bullet - significant cluster corrected p val
%
% Written by Esin Karahan, May, 2018
%

[ndti,ntr,ndir,npiece,nbehav] = size(pval);

if length(varargin) == 1
    saveflag = varargin{1};
else
    saveflag = 0;
end

for itr = 1:ntr
    figure,np = 1;
    for idt = dtiSel %MD, FA
        for icon = behavSel %RT, T0
            for  idd = 1:ndir
                subplot(2,4,np)
                plot(squeeze(rho(idt,itr,idd,:,icon)));
                % uncorrected p
                a = find(squeeze(pval(idt,itr,idd,:,icon))<pthr);text(a,rho(idt,itr,idd,a,icon),'\ast')
                % corrected p val - fdr or fwe
                b = find(squeeze(corrpval(idt,itr,idd,:,icon))<pthr);text(b,rho(idt,itr,idd,b,icon),'\color{red} \clubsuit') ;
                % corrected p val in the clutser level - fdr/fwe
                c = find(squeeze(corrpvalcluster(idt,itr,idd,:,icon))<pthr);text(c,rho(idt,itr,idd,c,icon), '\color{green} \bullet');
                grid;
                np=np+1;
                title([defn.trm{itr} '-' defn.dir{idd} ' ' defn.behav{icon}])
                axis tight
            end
        end
    legend(defn.dti((idt)),'Location','best')
    end
    if saveflag
        print(fullfile(defn.statdir,['minVox' num2str(defn.minVoxSeg)],[defn.trm{itr} '-' defn.dti{idt} '-' defn.addsmooth '-' num2str(piece) '-' varargin{1}]),'-dpng')
    end
end

