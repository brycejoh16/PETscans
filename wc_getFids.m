function fids=wc_getFids(directory)
%  WC_GETFIDS : recursively gets all the files in a give directory, including
%  files in subdirectories. 
%  INPUTS: 
%         directory: directory of all the files which would like to get
%         file ids 
%  OUTPUTS: fids:  all file ids in that directory 
%
% Author:  Tobey Betthauser 05202019 version 1.0
%          Bryce Johnson    08202019 version 1.1 ~ Added error checking         
% email : tjbetthauser@medicine.wisc.edu
% University of Wisconsin 
% __________________________________________________________________
%       ADRC ,  2019 

    if exist(directory,'dir')==0
        error('This directory %s, doesnt exist',directory);
    end 
    if ~endsWith(directory,'/')
        directory = [directory,'/'];
    end
      
    f1= dir([directory,'*']);
    f2 = dir([directory,'*/**']);
    files = cat(1,f1,f2);
    fids = strcat({files.folder},'/',{files.name})';
    fids = fids(~[files.isdir]); % if it is a directory don't use it. 
    
end 
