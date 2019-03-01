# create ROIs from Atlas
# FOR Cingulum Bundles

# Written by Esin Karahan, February 2019

atlasdir="/fsl.versions/5.0.9/data/atlases"

subjdir="/analyze/probtrackx/mask/Cingulum"

# ROIs #############################################
# Seed
#
# Cingulum 
atlasfold="Juelich"
atlasname="$atlasfold"-prob-2mm #4D
newname="Cingulum-R-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 95 1 -Tmax -thr 10 -bin $subjdir/$newname
newname="Cingulum-L-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 96 1 -Tmax -thr 10 -bin $subjdir/$newname
#
#
# Pick the anterior of Cingulum as seed
newname="Cingulum-Ant-R-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 95 1 -Tmax -roi 0 -1 76 12 38 43 0 -1 -bin $subjdir/$newname
newname="Cingulum-Ant-L-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 96 1 -Tmax -roi 0 -1 76 12 38 43 0 -1 -bin $subjdir/$newname
#
# Pick the posterior of Cingulum as stop
newname="Cingulum-Post-R-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 95 1 -Tmax -roi 0 -1 35 8 38 43 0 -1 -bin $subjdir/$newname
newname="Cingulum-Post-L-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 96 1 -Tmax -roi 0 -1 35 8 38 43 0 -1 -bin $subjdir/$newname
#
# Pick a slice in the middle as waypoint
newname="Cingulum-Mid-R-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 95 1 -Tmax -roi 0 -1 59 5 50 10 0 -1 -bin $subjdir/$newname
newname="Cingulum-Mid-L-prob-2mm"
fslmaths $atlasdir/$atlasfold/$atlasname -roi 0 -1 0 -1 0 -1 96 1 -Tmax -roi 0 -1 59 5 50 10 0 -1 -bin $subjdir/$newname
#

