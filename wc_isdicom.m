function dicoms=wc_isdicom(fids)
%  WC_ISDICOM: sees which files of the files ids are dicom files. by 
%  looking at the metadata in the dicom file. 
%
%  INPUTS: fids :  cell array of file ids : no directories 
%  OUTPUTS: dicoms: logical array of which files are dicoms
%
%  Author:  Bryce Johnson 08132019 version 1.0 
%  Email: joh14192@umn.edu
%  University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 

% assume that every file is not a dicom  false 
dicoms=false(numel(fids),1);
for i=1:numel(fids)
    fid=fids{i};
    % make a file reader;
    if isfolder(fid)
        % do nothing 
    else 
        % make a file reader 
        fr= matlab.io.datastore.DsFileReader(fid);
        % seek to the 128th byte 
        seek(fr,128,'RespectTextEncoding',true);
        
        if hasdata(fr)
            data = read(fr,4,'OutputType','char');
            % check to see if it has a DICM label 
            if contains(data,{'dicom','dicm','dcm','dcom'},'IgnoreCase',true)
                % if true this is a dicom file label this file as true. 
                dicoms(i)=true;
            end
        end
    end
end

end
