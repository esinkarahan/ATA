#!/bin/bash

# Register White matter/Grey matter images to the standard space (nonlinear)

# Written by Esin Karahan, March 2018

rootdir="/Desktop/SampleAnalysis" 

dtidir=${rootdir}/Data/dti
tractdir=${rootdir}/Data/probtrackx

# write the subjects name here
subjs=`cat $rootdir/subjectList.txt`
for ss in ${subjs}
do
	echo "registering gray/white matter of subject $ss"
	sd=$dtidir/$ss
	matFile=${tractdir}/"${ss}".bedpostX/xfms/str2standard_warp
	maskFile=/fsl/data/standard/MNI152_T1_2mm_brain_mask
	refVol=/fsl/data/standard/MNI152_T1_2mm_brain

	# nonlinear reg
    	# register GM to MNI
	applywarp --in=${sd}/"$ss"_seg_1 --ref=$refVol --mask=$maskFile --warp=$matFile --out=${sd}/"$ss"_seg_1_2_standard_nonlinear --interp=nn 

	# register WM to MNI
	applywarp --in=${sd}/"$ss"_seg_2 --ref=$refVol --mask=$maskFile --warp=$matFile --out=${sd}/"$ss"_seg_2_2_standard_nonlinear --interp=nn 
done
