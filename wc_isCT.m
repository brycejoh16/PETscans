function CT=wc_isCT(path_nii)
% WC_ISCT:  takes in a path to a nii study and then returns a logical array
% of which files are 3D CT images.
%
% Inputs:  path_nii: path to the nii study
% Outputs: CT: logical array of which files are 3D CT images. 
%
% Author:  Bryce Johnson 08202019 version 1.0
% email:  joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 


% get all the nifti fids. 
fidnii=wc_getdirfids(path_nii,'nii');

I=cellfun(@(x) {niftiinfo(x)},fidnii);

% make sure its a CT scan and that its a 3D image
CT=cellfun(@(x) (strcmp(x.Description,'CT') && ...
    x.raw.dim(1)>2),I);
% return the logical array. 
end