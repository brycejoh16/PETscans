function fid4D=wc_is4D(fids)
% WC_IS4D:  get the 4D files from a cell array of files, will return a logical array 
% of the files that are 4D. Will throw an error if no 4D files are found, or more 
% than one 4D file is found. (Uses metadata to determine dimension.) 
% Inputs: 
%       fids: cell array of character vectors of file ids 
% Outputs: 
%       fid4D: logical array of which files are 4D nii files
%
% Author:  Bryce Johnson 08202019 version 1.0
% email:  joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 
%
    if ischar(fids), fids=cellstr(fids);end
    fids=fids(endsWith(fids,'nii'));
    V = spm_vol(fids);
    fid4D=(cellfun('prodofsize',V)>1);
    if ~any(fid4D)
        error('No 4D files found');
%         wc_write2error(path_nii,['Error occurrued in script: ',mfilename,newline,...
%             'No dynamic PET series found in nii path: ']);
%         return 
    end
    
    if sum(fid4D)>1
        error('More than one 4D file found in a study');
%         wc_write2error(fid4D,['Error occurrued in script: ',mfilename,newline,...
%             'More than one dynamic PET series found: ']);
%         return 
    end
end 