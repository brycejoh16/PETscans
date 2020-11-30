function wc_def_norm_movement(nii_studies_path,xyzrpy_path,error_path)
% WC_DEF_NORM_MOVEMENT: define the normal movement across many nii studies by finding the
% standard deviation of movement parameters in the x,y, and z direction of
% returned from wc_motion_corr_4D across multiple studies. 
% Along with the roll, pitch, and yaw directions. 
% 
% Input: nii_studies_path: path to all the nii studies, has to follow the
%        same file tree as specified by wc_get_study_dir()
%        xyzrpy_path: path to where the xyzrpy.mat file should be stored,
%        should be a character vector of a directory. [defualt:pwd]
%        error_path: path to error_path.mat file, if not specified will
%        just look to matlab path. 
%
% Output:  xyzrpy.mat -- saves to the same location as error_path.mat 
%          Contains: 
%                   ->xyzrpy: standard deviation parameters for the
%                   acceptable movement for [x,y,z,roll,pitch,yaw]
%
%                   ->meanxyzrpy: the mean value of all the movements, all
%                   should be quite close to zero
%
%                   ->nbOfStudies:  number of studies used to determine the
%                   normal movement parameters. More studies used the
%                   better. 
%
% Author:  Bryce Johnson 08202019 version 1.0
% email: joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 


if nargin<3,error_path=[];end % just look to matlab path
if nargin<2,xyzrpy_path=pwd;end

% check the error file. 
wc_check_error_path(error_path)


% get all the nii study directory ids 
niiStudies=wc_get_study_dir(nii_studies_path);

% get the rotation parameters for the nii studies 
rp=getrp(niiStudies);


%std returns the standard deviation of an array of numbers. 
xyzrpy=std(rp);
meanxyzrpy=mean(rp);
nbOfStudies=numel(niiStudies);

filename_xyz=[xyzrpy_path,'/xyzrpy.mat'];
save(filename_xyz,'xyzrpy','meanxyzrpy','nbOfStudies','rp');
matfile(filename_xyz,'Writable',false);

end 


%------------------------------------------------------------------
% getrp: gets the rotation parameters for every nifti study. Returns in a
% nx6 double array. 
%------------------------------------------------------------------
function rp=getrp(niiStudies)

for i=1:numel(niiStudies)
    
   opts=struct('doMotion',false);
    try 
       studyrp=wc_motion_corr_4D(niiStudies{i},opts);
       if i==1
            rp=studyrp;
       else
            rp=[rp;studyrp];
       end
    catch errorStruct
        wc_write2error(niiStudies{i},errorStruct,'Couldnt get the rp matrix from the following nii study: ');
    end 
end

end