function wc_dicom2origin(path_dicom)
% WC_DICOM2ORIGIN: Put dicom image at the AMIDE origin for 
% for the x,y, and z coordinates and flip the pixel data. 
% This will cause the dicom image to overlay with
% the converted nifti image when it is in AMIDE
% 
% Input: 
%     dicom_path: path to all the dicom files of one study]
% Output: 
%    new dicom slices with changed ImagePositionPatient field and pixel data flipped. 
%    It will not create new slices it will overload the current images 
% __________________________________________________________________
% Theory: 
% x and y positions:  Amide tries to find the origin of the image by taking
% half the number of pixels in the x and y direction and then multiplying
% that by the scaling factor. It then adds that value to the ImagePositionPatient
% field, so if originally it is its negative Amide will place image at origin.
%
% z position: the Original ImagePositionPatient minus the mean of all the z
% slices minus one will cause it to go the origin...little logic there but
% it works...
%
% spm_convert_dicom line 651 is the fliplr() flips the plane, so must undo
% that by flipping the pixel data back. 
%
%
% Author:  Bryce Johnson 08132019 version 2.0
% email: joh14192@umn.edu
% University of Wisconson 
% __________________________________________________________________
%       Waismann Center , Aug 2019 


 disp(['Converting dicom directory: ',path_dicom]);
fids=wc_getdirfids(path_dicom,'dicom');

% get dicom headers 
hdrs=spm_dicom_headers(fids);
% find the 3D images
is3D=(cellfun(@(x) (~isempty(x) && isfield(x,'PixelSpacing') && isfield(x,'SliceThickness')),hdrs));
% filter out 3D images
hdrs=hdrs(is3D);
fids=fids(is3D);
% make cell array for specific series 
series=unique(cellfun(@(x) x.SeriesInstanceUID,hdrs,'uni',false));
for j=1:numel(series)
    % filter out so only have one 3D series 
    is_series=(cellfun(@(x) (strcmp(x.SeriesInstanceUID,series{j})),hdrs));
    series_hdr=hdrs(is_series);
    series_fids=fids(is_series);
    
    % get the current image position patient 
    D=cellfun(@(x) x.ImagePositionPatient,series_hdr,'uni',false);
    z=mean(cellfun(@(x) x(3),D));

    % rewrite all the planes 
    for i=1:numel(series_hdr)
        fid=series_fids{i};
        d=dicominfo(fid);
        V=dicomread(fid);
        % flip the data to match nifti file 
        % spm_convert_dicom line 651 is the fliplr() flips the plane 
        V=fliplr(V);
        % change x,y,z values 
        xdcm=-((double(d.Columns)*double(d.PixelSpacing(1)))/2);
        ydcm=-((double(d.Rows)*double(d.PixelSpacing(2)))/2);
        zdcm=double(d.ImagePositionPatient(3))-z-1;
        d.ImagePositionPatient(:)=[xdcm,ydcm,zdcm];
        % rewrite slice
        dicomwrite(V,fid,d,'CreateMode','copy'); 
    end
end

end 
