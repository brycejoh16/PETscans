function wc_write2error(fids,errorStruct,msg,error_path,fileName)
% WC_WRITE2ERROR: writes to a csv file a list of files which data was not
% processed correctly, as opposed to writing an error to the user. Can be useful when
% processing large amounts of data.(try -- catch statements) 
% Input: 
%       fids: file ids in a cell array of character vectors
%       msg: message to display on error file as to why those files failed
%       if known. [Default: 'Following files were not processed properly:']
%       errorStruct:a MException object 
%       error_path: path to the directory to save the error file to as a
%       charactor vector. [Default: finds error_path.mat file and uses that 
%          directory]
%       fileName: name of error file as a character vector. [Default:
%       errorcatch.csv]
%
% Output: 
%       csv file specifying the errors that occured for specific files.
%       Saved to path specified by error_path.mat file. 
%
% Author:  Bryce Johnson 08132019 version 2.0 
% Email: joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 

% check input for message. 
if nargin<5,fileName='errorcatch.csv';end
if nargin<4
    load error_path.mat error_path
    if isempty(error_path)
        error('Must specify fullpath in error_path.mat for error files');
    end
end
if nargin<3,msg='Following files were not processed properly: ';end

if ~isobject(errorStruct)
    errormsg=['At: ',datestr(now),newline,errorStruct];
else 
    errormsg=writeErrorMsg(errorStruct,msg);
end 

% if the input is a char array or char vector 
if ischar(fids)
    fids=cellstr(fids);
end


fileNameFP=[error_path,'/',fileName];
if exist(fileNameFP,'file')==0
    fileID=fopen(fileNameFP,'w'); 
    if fileID==-1
        error('Failed to open file: %s',fileNameFP);
    end 
    fprintf(fileID,['\n',errormsg,'\n']);
else 
    fileID=fopen(fileNameFP,'a');
    fprintf(fileID,['\n',errormsg,'\n']);
end 
fprintf(fileID,'%s\n',fids{:});
if ~fclose(fileID)==0
    error('Failed to close file: %s',fileNameFP);
end

end

function errormsg=writeErrorMsg(errorStruct,msg)
    errormsg=['At: ',datestr(now),newline,'Error:  ',errorStruct.message];
    for i=1:numel(errorStruct.stack)
        errorstack=errorStruct.stack(i);
        errormsg=[errormsg,newline,'Error: ',errorstack.name,...
            ' at line ',num2str(errorstack.line),'^^'];
    end
    errormsg=[errormsg,newline,msg];
end 