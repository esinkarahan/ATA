function borderRoi = bordersWayPointROI_CST(defn)
% Find the top and bottom planes defined by the ROIs of CST
% The z coordinates of the vectors are important
% 
% Esin Karahan, February, 2018

maskdir = fullfile(defn.trackdir,'mask','CST');

mask  = {'Cerebral-Peduncle','SCR'};
d     = {'R' 'L'};

Cfirst=cell(2);Clast=Cfirst;
for i=1:length(mask)
    for j=1:length(d)
        imname=fullfile(maskdir,[mask{i} '-' d{j} '.nii.gz']);
        voxel = loadImageSpm(imname);
        % For topDown orientation pick 3
        [Cfirst{i,j},Clast{i,j}] = findFirstandLastPointsTract(voxel,3);
    end
end
borderRoi{1} = [Cfirst{1,1}; Clast{2,1}]; % right
borderRoi{2} = [Cfirst{1,2}; Clast{2,2}]; % left
end