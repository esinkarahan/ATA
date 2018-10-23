#!/bin/bash

# Register White matter images to b0 native space

# Written by Esin Karahan, March 2018

rootdir="/home/sapek5/Desktop/SampleAnalysis" 

datadir=${rootdir}/"Data"
dtidir=${rootdir}/Data/dti
tractdir=${rootdir}/Data/probtrackx

# write the subjects name here
subjs=`cat ${datadir}/subjectList.txt`

# T1 --> White matter
for ss in ${subjs}
do
  echo "Registering subject: ${ss}"	
  cd ${dtidir}/${ss}
  # reference volume - b0 (after betting)
  refVol=${dtidir}/"${ss}"/"nodif_brain"
  # transformation file
  matFile=${tractdir}/"${ss}".bedpostX/xfms/"str2diff.mat"
  # white Matter image
  wm=${dtidir}/"${ss}"/"${ss}"_seg_2  
  regwm=${dtidir}/"${ss}"/"${ss}"_seg_2_2_native  
  flirt -in $wm -ref $refVol -out $regwm -init $matFile -applyxfm -interp nearestneighbour
  fslmaths $regwm -bin $regwm
done
