function tarfid=wc_dicom2nii(dicom_path,nii_path,doAmideReslice)
% DICOM2NII--> takes in a path to a dicom study and then converts all the
% series in that study to nii files. It produces a 4D image if one is found
% from a dynamic pet series. 
% Input:
%   dicom_path: path to all the dicom files of only one study 
%   nii_path: directory to save the nii files to.'
%   doAmideReslice : T/F boolean on whether to reslice dicom images to
%   overlay with nifti in amide. Not recommended if dont want to change
%   original dicom images. However, code in wc_dicom2origin could be
%   improved to account for this, i.e. output to a different directory.
%   [default: false] 
% Output: 
%   tarfid:  cell array of tar files which contain 3D nii vols and an html
%   file which displays dicom header info from a single slice of the
%   volume. 
%   
%   
%
% Author:  Bryce Johnson 08202019 version 2.0
% email:  joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 
if nargin<3, doAmideReslice=false;end
disp(['Now performing dicom2nii conversion on dicom path: ',dicom_path]);

% get all the header information from dicom path
headers=get_headers(dicom_path);
 
if isempty(headers)
     % there was an error in taking in data for this study, just return out
     % of function and move onto next study. 
     tarfid={};
    return 
end


% convert the dicom slices into nifti 3D volumes
tarfid=convert2nii(headers,nii_path);

tarfid=tarfid(~cellfun('isempty',tarfid));

% move dicom file to 'origin' so in Amide it overlays with nifti image;

if doAmideReslice 
    wc_dicom2origin(dicom_path);
end

end
%------------------------------------------------------------------
% GET_HEADERS: get all header information from dicom path, if an error
% occurs it will write all files which lost header information to
% [dicom_path,'/errorcatch.csv']. Will then display which series are being
% converted to nii and which are not. 
% INPUT: 
%   dicom_path--> path to all the dicom files
%------------------------------------------------------------------
function headers=get_headers(dicom_path)
    
    
    % read in all the dicom files 
    fids=wc_getdirfids(dicom_path,'dicom');
    
    % if there are no dicom files in this directory then return 
    if isempty(fids)
        headers={};
        return 
    end
    
    disp('Reading dicom headers');
    headers=spm_dicom_headers(fids);

    
    % find the 3D images
    is3D=cellfun(@(x) (~isempty(x) && isfield(x,'SliceThickness')),headers);
    image2D=headers(~is3D);
    headers=headers(is3D);
    
    % say which series are 2D images
    if ~isempty(image2D)
        descrip=unique(cellfun(@(x) [strrep(x.SeriesDescription,' ','_'),', '],...
            image2D,'uni',false));
        disp(['Not converting ',num2str(numel(descrip)),' series: ',descrip{:},...
            newline,' because they dont appear to be 3D volumes.']);
    end
    
    % Say which series are being converted 
    hdrdescrip=unique(cellfun(@(x) [strrep(x.SeriesDescription,' ','_'),', '],...
        headers,'uni',false));
    disp(['Converting ',num2str(numel(hdrdescrip)),' series: ',hdrdescrip{:},...
        newline,'because they are 3D images']);
end

%------------------------------------------------------------------
% CONVERT2NII: does the actual conversion of the dicom files to the nii
% format. Right now make a whole new study folder with series
% subdirectories.
% Inputs: 
%    headers-->  cell array of headers from spm_dicom_headers
%    nii_path--> path to directory of where to save the new nii files
% Outputs:
%    tarfid:  a cell array containing character vectors of .tar file ids 
%------------------------------------------------------------------
function tarfid=convert2nii(headers,nii_path)

    % find all the unique series 
    series=unique(cellfun(@(x) x.SeriesInstanceUID,headers,'uni',false));
    tarfid=cell(numel(series),1);
    
    
    for i=1:numel(series)
        series_hdr=headers(cellfun(@(x) (strcmp(x.SeriesInstanceUID,... 
            series{i})),headers));
        
        V=spm_dicom_convert(series_hdr,'all','patid','nii',nii_path,false);

        niifid=char(V.files);
        
        if size(niifid,1)>1

              V4=spm_file_merge(niifid);
              
              % delete the files that were just merged. 
              delete(V.files{:});
              niifid=V4(1).fname;
        end 
        

        %  make the headerfile
        hdrfid=makeHTMLheader(niifid,series_hdr{1});
        
        %  make the tar file 
        tarfileName=makefileName(niifid,'','tar');
        tar(tarfileName,{hdrfid,niifid});
        % gzip the files
        gzip(tarfileName,fileparts(tarfileName));
        

        tarfid{i}=[tarfileName,'.gz'];
        
        % now delete the files that are untarred... 
    %     this step may is uneccessary here though. 
        if ~exist(tarfid{i},'file')==0
            delete(hdrfid,niifid,tarfileName);
        end 
    
    end 
end 
%------------------------------------------------------------------
% MAKEHTMLHEADER: makes a html file of a dicom header information
% for one slice in a series. 
%Inputs: 
%       nii file id: the file id of the nii file
%       dicom_hdr:  a single dicom header struct from spm_dicom_headers.
%------------------------------------------------------------------
function hdrfid=makeHTMLheader(niifid,dicom_hdr)
    hdrfid=makefileName(niifid,'header_','html');
    d=dicominfo(dicom_hdr.Filename); % dicom header struct 
    d.Filename=niifid;
    options={'title',['Header info for file:',newline,hdrfid]; ...
   'useCSS',1; };
    print2html(d,Inf,hdrfid,options);
end

%------------------------------------------------------------------
% MAKEFILENAME: makes a newfile name from a previous file. Outputs it in
% the following format. [filepath,'/',message,(old) fileName, extension].
% Inputs: file: file to be converted with fullpath. 
%         message: message that should be inserted before the fileName if
%         no message wanted and just a change in extension use ''. 
%         ext: extension to change the file, i.e. 'html' or 'csv' etc. 
% Output: 
%         returnFile:  the file id returned after the name has been changed. 
%------------------------------------------------------------------
function returnFile=makefileName(file,msg,ext)
if startsWith(ext,'.')
    ext=ext(2:end);
end 
if startsWith(msg,'/')
    msg=msg(2:end);
end 

[filepath,fileName]=fileparts(file);
returnFile=[filepath,'/',msg,fileName,'.',ext];

end 
