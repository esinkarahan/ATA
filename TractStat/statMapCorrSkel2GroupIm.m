% Script for mapping the significant correlation from skeleton back to the group image
% Subvolumes in the tract that correspond to the significant segments in the tract 
% are saved as an image file. The intensity of the voxels in an image could
% be p values or beta values.
%
% Written by Esin Karahan, May, 2018
%
clear

run('setDirectory.m')
run('setDefinition.m')

defn.addsmooth=''; npiece = 30;
bval_list = {'multi', '1200'};
noddi_list = {'noddi', ''};
stat_type = 'tfce';
pval_type = 'fwe';
% stat_type='dat';
% pval_type = 'uncp';


tic,
for k=1:length(noddi_list) %noddi
    if strcmp(noddi_list{k},'noddi')
        defn.dti     = {'RobustmeanND','RobustmeanODI','weightND','weightODI'};
    else
        defn.dti     = {'RobustmeanFA','RobustmeanMD','weightFA','weightMD'};
    end
    defn.noddi =noddi_list{k};
    bval = bval_list{k};
    imdir = fullfile(defn.statdir,['minVox' num2str(defn.minVoxSeg)],bval);
    load(fullfile(imdir,['stat-' defn.noddi '-' defn.addsmooth '-' num2str(npiece) '-' bval '-' defn.con{1} '-' stat_type '.mat']));
    [ndti,ntr,ndir,npiece,nbehav,nsign] = size(pval);
    statsign = {'pos','neg'};

    % define V0 here
    V0.dt     = [64 0];
    V0.pinfo  = [1;0;0];
    V0.n      = [1 1];
    V0        = setfield(V0,'private',[]);
    V0.dim    = [91,109,91];
    V0.mat    = [-2,0,0,92;0,2,0,-128;0,0,2,-74;0,0,0,1];
    
    pthr = 0.05;
    im=1;%thin
    for idt = 1:ndti %FA, MD or NDI, ODI
        for itr = 1:ntr %OR, CST
            for  idd = 1:ndir
                for icon = 1:nbehav-1 %RT, T0
                    for isign = 1:nsign %pos, neg
                        a = find(squeeze(pval(idt,itr,idd,:,icon,isign))<pthr); %uncorrected
                        b = find(squeeze(fdr(idt,itr,idd,:,icon,isign))<pthr); %cluster level fdr corrected
                        c = find(squeeze(fwevalcluster(idt,itr,idd,:,icon,isign))<pthr); %cluster level fwe corrected
                        
                        if strcmp(pval_type,'uncp')
                            pvalSel = a;
                        elseif strcmp(pval_type,'fdr')
                            pvalSel = b;
                        elseif strcmp(pval_type,'fwe')
                            pvalSel = c;
                        end
                        
                        if ~isempty(pvalSel)
                            % find the real equivalent of the
                            % piece order
                            tractFol = [defn.tr{itr} '-' defn.dir{idd} '.probtrackX.' defn.regMethod '.Stop'];
                            rnonans  = findIgnoranceColumns(defn,idt,tractFol,maindir);
                            % load the segments form the start
                            ntractSkelInfo = fullfile(defn.outdir,tractFol,['SkelOverlap' defn.skelMethod{im} num2str(npiece) '.mat']);
                            load(ntractSkelInfo)
                            % map c back to the segment order
                            nseg = size(rnonans,1); %actual number of segments
                            tt = 1:nseg;
                            tt = tt(rnonans);
                            cback = tt(pvalSel);
                            % create the image
                            V = V0;
                            V.fname = fullfile(imdir,[defn.trm{itr} '-' defn.dir{idd} '-' num2str(npiece) '-' defn.dti{idt} '-' bval_fa '-' defn.con{icon} '-' defn.addsmooth '-' stat_type '-' pval_type '-' statsign{isign} '.nii']);
                            V.private.dat.fname = V.fname;
                            Im = zeros(V.dim);
                            
                            nc = length(pvalSel);
                            for ii = 1:nc
                                %list of the voxels that should be included in the
                                %image
                                selvox = unique(reshape(assignMatSkel(cback(ii),:),1,[]));
                                selvox = selvox(selvox>0);
                                indvox = sub2ind(V.dim,assignInd(selvox,1),assignInd(selvox,2),assignInd(selvox,3));
                                % binary image
                                % Im(indvox) = 1; 
                                % p-values of the FWE 
                                Im(indvox) = fwevalcluster(idt,itr,idd,c(ii),icon,isign); 
                                % beta values
                                % Im(indvox) = cope(idt,itr,idd,pvalSel(ii),icon,isign);
                            end
                            spm_write_vol(V,Im);
                            gzip(V.fname)
                            delete(V.fname)
                            
                            if sum(ismember(defn.dti{idt},'weight'))==6
                                %binarize
                                Im(Im>0) = 1;
                                V.fname = fullfile(imdir,[defn.trm{itr} '-' defn.dir{idd} '-' num2str(npiece) '-' defn.dti{idt} '-' bval_fa '-' defn.con{icon} '-' defn.addsmooth '-' stat_type '-' pval_type '-' statsign{isign} '-bin.nii']);
                                V.private.dat.fname = V.fname;
                                spm_write_vol(V,Im);
                                gzip(V.fname)
                                delete(V.fname)
                            end
                            
                        end
                    end
                end
            end
        end
    end
   
end


