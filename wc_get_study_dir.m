function dirids=wc_get_study_dir(path_studies)
% WC_GET_STUDY_DIR: gets the study directories from each image study, also
% checks to make sure it is in the following format:
% ParentDirectory/Study1/
%              ../Study2/
%              ../Study3/
%                   .
%                   .
%                   .
%              ../StudyN/
% 
% Will throw an error if not in this format so be careful. 
% The choice to use this file organization was made as it makes sure the
% user has studies properly organized and not overlaping.
% 
% Inputs: 
%          path_studies: a character vector specifying the path to all dicom
%          studies. 
% Output: 
%          dirids: A cell array of character vectors specifying the path
%          to each study under path_studies. 
%
% Author:  Bryce Johnson 08202019 version 1.0
% email:  joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019  

% check inputs
if exist(path_studies,'dir')==0
    error(['This is not a directory: ',path_studies]);
end 

d1=dir(path_studies);
dirids=strcat({d1.folder},'/',{d1.name});
dicomfids=wc_isdicom(dirids);
if any(dicomfids)
    error(['Seems as though there are dicom files not in the proper tree hiearchy',newline,...
        'Make sure your dicom hierarchy looks like this with no stray dicom files: ',newline,...
        '---------------------------------------------------------------------------',newline,...
        '          Dicoms/Study1/',newline,...
        '              ../Study2/',newline,...
        '              ../Study3/',newline,...
        '                   .',newline,...
        '                   .',newline,...
        '                   .',newline,...
        '              ../StudyN/',newline,...
        ' See ',mfilename, ' for more details.',newline,...
        '---------------------------------------------------------------------------']);
end

% account for '.' and '..' directory names
dirids=dirids([d1.isdir]);
dirids=dirids(~endsWith(dirids,{'.','..'}));
if isempty(dirids)
    error(['There dont seem to be any study directories in this study path',newline,...
        'Make sure your dicom hierarchy contains studies',newline,...
        '---------------------------------------------------------------------------',newline,...
        '          Dicoms/Study1/',newline,...
        '              ../Study2/',newline,...
        '              ../Study3/',newline,...
        '                   .',newline,...
        '                   .',newline,...
        '                   .',newline,...
        '              ../StudyN/',newline,...
        ' See ',mfilename, ' for more details.',newline,...
        '---------------------------------------------------------------------------']);
end


end

