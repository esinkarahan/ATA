function subjname = readSubjectsFromFile(fileName)
% Read subject names from txt file in which subject names are separated
% with a white space
% 
% Input
% fileName - file that contains subject names
% 
% Output
% subjname - cell array 
%
% Written by Esin Karahan, October, 2017

    [~, ~, ext] = fileparts(fileName);
    if strcmp(ext,'txt')
        display('Subject names should be a text file');
        return;
    end
    s=importdata(fileName,' ');
    subjInd=regexp(s,'\w*');
    l=length(subjInd{1});
    subjname=cell(l,1);
    for i=1:l-1
        subjname{i}=s{1}(subjInd{1}(i):subjInd{1}(i+1)-2);
    end
    subjname{l}=s{1}(subjInd{1}(l):end);
end