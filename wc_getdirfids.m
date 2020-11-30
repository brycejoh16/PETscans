function fids=wc_getdirfids(path_files,ext,nb)
% WC_GETDIRFIDS: outputs all files in a directory of a certain file type. 
% Will uncompress all .tar, bz2, and .gz, and .bz2 files. Will keep going
% until every file has been opened so be careful. (Infinite Loop)
% INPUTS: 
%           path_files: a character array of the path to the directory
%           which all the files are located. [default:pwd]
%           ext: the file extension of the files one wishes to extract.
%           [default: dicom]
%           Can not handle multiple file types extraction yet. That can be
%           updated. 
%           nb: The number of files that can be gunzipped onto disk. 
%           for wc_decompress, look there for more details. 
%           [default: 6 -->  number of nii files in a PiB study]

% OUTPUTS:  
%           fids: file ids of all the files in a directory with the
%           specified ext. 
%
% Possible Improvements: This function can be improved by making the is
% dicom() a local function that takes in a byte value and an cell array for
% contains in order to determine what the files are. This is better than
% endsWith as it doesn't conceal information in the filename. 
%
% Author:  Bryce Johnson 08202019 version 2.0
% email: joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 


% for testing:
% ext='dcm';
% path_files='/Users/bryce.johnson/Desktop/PETScans/dicom2niftiTester/dicmFiles/dicomsMK';
if nargin<3, nb=6;end
if nargin<2, ext='dicom';end
if nargin<1,path_files=pwd;end

% decompress for all compression types: .tar, bz2, and .gz, and .bz2
wc_decompress(path_files,nb);

% decompress all files and get file ids
fids=wc_getFids(path_files);

% now filter out just the files to correct format. I'm making it a cell
% array so it will be easy to add another function handle
% use this method if there are lots of wierd filtering, like for Dicom. 
% states={@isDicom,@isNifti;'dicom','nii'};

if contains(ext,{'dicom','dicm','dcm','Dicom','dcom','DICOM','d','D'})
    fids=fids(wc_isdicom(fids));
else
    % return the necessary files. 
    if contains(ext,{'nifti','N','n','NIfTI','nfti','nfi','NIFTI','nii'})
        ext='.nii';
    end 
    fids=isFile(fids,ext);
end 



end 

% -----------------------------------------------------------------------
%  isFile(fids) --> sees which files of the files ids are ext files. 
%  INPUTS: fids :  cell array of file ids : no directories 
%          req_ext:  the extension of files to return. 
%  OUTPUTS: fids: fids of all the nii files.  
% -----------------------------------------------------------------------

% this is a bad function. 
function files=isFile(fids,ext)
files=fids(endsWith(fids,ext));
end

