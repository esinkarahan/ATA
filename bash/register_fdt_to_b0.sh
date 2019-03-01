#!/bin/bash

# Register the fdtpaths calculated by the probtrackx back to dti native space

# Written by Esin Karahan, February 2018

rootdir="/Desktop/SampleAnalysis" 

datadir=${rootdir}/"Data"
dtidir=${rootdir}/Data/dti
tractdir=${rootdir}/Data/probtrackx

# write the subjects name here
subjs=`cat ${datadir}/subjectList.txt`

trs="OR-way CST"
dirs="L R"

for ss in ${subjs}
do
  for tr in ${trs}
  do
    for dir in ${dirs}
    do
      echo "registering $ss $tr $dir"
      # reference volume
      refVol=${dtidir}/"${ss}"/"nodif_brain"
      # for nonlinear reg
      tractFol=${tractdir}/"${ss}"."${tr}"-"${dir}".probtrackX.Nonlinear.Stop/"fdt_paths"
      matFile=${tractdir}/"${ss}".bedpostX/xfms/"standard2diff_warp"
      regfdt=${tractdir}/"${ss}"."${tr}"-"${dir}".probtrackX.Nonlinear.Stop/"fdt_paths_reg"
      maskVol=${dtidir}/"${ss}"/nodif_brain_mask
      applywarp --in=$tractFol --ref=$refVol --mask=$maskVol --warp=$matFile --out=$regfdt --interp=nn 
    done
  done
done


