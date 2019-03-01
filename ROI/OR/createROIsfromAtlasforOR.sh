# create ROIs from Atlas
# FOR CST

# Written by Esin Karahan, February 2019

atlasdir="/fsl.versions/5.0.9/data/atlases"
subjdir="/analyze/probtrackx/mask/OR"

#####################Juelich############################
atlasfold="Juelich"

#### Generate maps from probabilistic OR, LGN, OR
atlasfold="Juelich"
atlasname="$atlasfold"-prob-2mm #4D

newname="Juelich-V1-R-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 81 1 -Tmax -thr 10 -bin $subjdir/$newname

newname="Juelich-V1-L-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 80 1 -Tmax -thr 10 -bin $subjdir/$newname

newname="Juelich-LGN-R-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 102 1 -Tmax -thr 10 -bin $subjdir/$newname

newname="Juelich-LGN-L-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 103 1 -Tmax -thr 10 -bin $subjdir/$newname

newname="Juelich-OR-R-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 107 1 -Tmax -thr 10 -bin $subjdir/$newname

newname="Juelich-OR-L-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 108 1 -Tmax -thr 10 -bin $subjdir/$newname

# waypoint
newname="Juelich-ORway-R-2mm"
fslmaths $subjdir/Juelich-OR-R-prob-2mm -roi 0 -1 44 3 0 -1 0 -1 -bin $subjdir/$newname

newname="Juelich-ORway-L-2mm"
fslmaths $subjdir/Juelich-OR-L-prob-2mm -roi 0 -1 44 3 0 -1 0 -1 -bin $subjdir/$newname

##################################################################################################################

#exclusion mask MNI
atlasdir="/fsl.versions/5.0.9/data/standard"
atlasname="MNI152_T1_2mm_brain_mask" #4D
newname="exclusionMask-MidLine-R-2mm"
fslmaths $atlasdir/$atlasname -roi 41 4 42 -1 0 -1 0 -1 $subjdir/$newname

atlasdir="/fsl.versions/5.0.9/data/standard"
atlasname="MNI152_T1_2mm_brain_mask" #4D
newname="exclusionMask-MidLine-L-2mm"
fslmaths $atlasdir/$atlasname -roi 45 4 42 -1 0 -1 0 -1 $subjdir/$newname

newname="exclusionMask-Coro-2mm"
fslmaths $atlasdir/$atlasname -roi 0 -1 64 -1 0 -1 0 -1 $subjdir/$newname

newname="exclusionMask-Add-L-2mm"
fslmaths $subjdir/exclusionMask-MidLine-L-2mm -add $subjdir/exclusionMask-Coro-2mm -bin $subjdir/$newname
fslmaths $subjdir/$newname -add /analyze/probtrackx/mask/Right-Hemi -bin $subjdir/$newname

newname="exclusionMask-Add-R-2mm"
fslmaths $subjdir/exclusionMask-MidLine-R-2mm -add $subjdir/exclusionMask-Coro-2mm -bin $subjdir/$newname
fslmaths $subjdir/$newname -add /analyze/probtrackx/mask/Left-Hemi -bin $subjdir/$newname


