#!/bin/bash

# Segment T1 images

# Written by Esin Karahan, March 2018

rootdir="/Desktop/SampleAnalysis" 
datadir=${rootdir}/"Data"
T1dir=${rootdir}/Data/T1
dtidir=${rootdir}/Data/dti

# write the subjects name here
subjs=`cat ${datadir}/subjectList.txt`

for ss in ${subjs}
do
  echo "Segmenting subject: ${ss}"	
  cd ${T1dir}/${ss}
  sd=${dtidir}/${ss}

  # segment T1
  fast -S 1 -t 1 -n 3 -H 0.1 -I 4 -l 20.0 -g -o ${sd} $T1dir/$ss/"$ss"_T1_bet
  # remove redundant files
  rm $sd/*pve* $sd/*bias* $sd/*seg_0* $sd/*seg_1* $sd/*mixeltype* $sd/*_seg.nii.gz
done
