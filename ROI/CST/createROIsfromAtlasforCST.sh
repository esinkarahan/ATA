# create ROIs from Atlas
# FOR CST

# Written by Esin Karahan, February 2019

atlasdir="/fsl.versions/5.0.9/data/atlases"
atlasfold="HarvardOxford"
atlasname="$atlasfold"-cort-maxprob-thr25-2mm

subjdir="/analyze/probtrackx/mask/CST"

# precentral gyrus
newname="Precentral-Gyrus-R"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 7 -uthr 7 -bin -roi 0 45 0 -1 0 -1 0 1 $subjdir/$newname 

newname="Precentral-Gyrus-L"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 7 -uthr 7 -bin -roi 46 -1 0 -1 0 -1 0 1 $subjdir/$newname 


## CST atlas
atlasfold="Juelich"
atlasname="$atlasfold"-prob-2mm #4D

newname="Juelich-CST-L-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 98 1 -Tmax -thr 10 -bin $subjdir/$newname

newname="Juelich-CST-R-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 97 1 -Tmax -thr 10 -bin $subjdir/$newname



#####################JHU############################

# posterior limb of internal capsule
atlasfold="JHU"
atlasname="$atlasfold"-ICBM-labels-2mm

newname="PLIC-L"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 20 -uthr 20 -bin $subjdir/$newname

newname="PLIC-R"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 19 -uthr 19 -bin $subjdir/$newname

newname="Cerebral-Peduncle-L"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 16 -uthr 16 -bin $subjdir/$newname 

newname="Cerebral-Peduncle-R"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 15 -uthr 15 -bin $subjdir/$newname 

# superior corona radiata
newname="SCR-L"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 26 -uthr 26 -bin $subjdir/$newname

newname="SCR-R"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 25 -uthr 25 -bin $subjdir/$newname

#####################JHU############################
#create exclusion masks
#right hemisphere
newname="Right-Hemi"
fslmaths /fsl.versions/5.0.9/data/standard/MNI152_T1_2mm_brain_mask.nii.gz -roi 0 45 0 -1 0 -1 0 1 $subjdir/$newname

newname="Left-Hemi"
fslmaths /fsl.versions/5.0.9/data/standard/MNI152_T1_2mm_brain_mask.nii.gz -roi 46 -1 0 -1 0 -1 0 1 $subjdir/$newname

# inferior cerebellar peduncle 
newname="ICP-L"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 12 -uthr 12 -bin $subjdir/$newname

newname="ICP-R"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 11 -uthr 11 -bin $subjdir/$newname

# mediul lemniscus 
newname="ML-L"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 10 -uthr 10 -bin $subjdir/$newname

newname="ML-R"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 9 -uthr 9 -bin $subjdir/$newname

# superior cerebellar peduncle 
newname="SCP-L"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 14 -uthr 14 -bin $subjdir/$newname

newname="SCP-R"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 13 -uthr 13 -bin $subjdir/$newname

# anterior limb of internal capsule 
newname="ALIC-L"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 18 -uthr 18 -bin $subjdir/$newname

newname="ALIC-R"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 17 -uthr 17 -bin $subjdir/$newname

#pontine crossing tract
newname="PCT"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 2 -uthr 2 -bin $subjdir/$newname

#retrolenticular part of internal capsule
newname="RLIC-L"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 22 -uthr 22 -bin $subjdir/$newname

#retrolenticular part of internal capsule
newname="RLIC-R"
fslmaths $atlasdir/$atlasfold/$atlasname -thr 21 -uthr 21 -bin $subjdir/$newname



