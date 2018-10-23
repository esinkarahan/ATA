
% Run this to set the name of the variables and directories before starting
% the analysis
clear;

run('setDirectory.m')
run('setDefinition.m')

% output directory
mkdir(defn.statdir)
mkdir(defn.tractstatdir)


