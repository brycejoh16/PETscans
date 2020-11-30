function rp=wc_motion_corr_4D(path_nii,opts)
% WC_MOTION_CORR_4D: Checks the alignment of nii 4D files. 
% Will write files which are bad to an error catch .csv file. 
% if any of the motion parameters are beyond the accepted movement amount defined
% by xyzrpy.mat from wc_def_norm_movement. Will not check if it is aligned
% if xyzrpy.mat file doesn't exist with the variable xyzrpy 1x6 double
% array. 
% Input: 
%       path_nii -> path to a PET study containing .nii files and one 
%        4D PET Series volume;
%
%       opts: a struct definng the possible options for motion checking;
%                   opts.nb: number of acceptable studies to for defining
%                   normal parameters [default: 10]
%
%                   opts.stdev: number of standards of deviations the
%                   rotation parameters can be before writing to the error
%                   file. [default: 3]
%
%                   opts.percent: percent of the rigid motion parameters
%                   [default: 10]
%
%                   opts.doMotion: a T/F value in which true means it will check the
%                   motion of the rigid motion parameters against the normal values.
%                   (wc_check_motion). This value is mainly here if running
%                   wc_def_norm_movement and xyzrpy.mat is already defined.
%                   [Default:true]
%
%                   opts.xyzrpy_path: path to xyzrpy .mat file,[default: will
%                   just look to matlab path]
%
% Output: 
%       rp:  the adjustment parameters after the motion correction,in a
%       double nx6 array. Where n is the number of frames plus 1. 
%       (x,y,z) -->  in mm
%       (roll, pitch,yaw)--> in rad
% 
% 
%
% Author:  Bryce Johnson 08202019 version 2.0
% email:  joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 

%   input arguments error checking. 
    
    if exist(path_nii,'dir')==0
        error(['This study does not exist. Make sure path_nii is a directory ',...
                    'in script: ']);
    end 
    if nargin<2
        opts=struct('stdev',3,'nb',10,'percent',10,'doMotion',true);
    else
        % check the opts field
        if ~isfield(opts,'nb'),opts.nb=10;end
        if ~isfield(opts,'stdev'),opts.stdev=1;end
        if ~isfield(opts,'percent'),opts.percent=10;end
        if ~isfield(opts,'doMotion'),opts.doMotion=true;end
    end
    
    % decompress files if they are compressed
    wc_decompress(path_nii,6); % max of 6 files allowed to unzip at a time
    

    % select all NIfTI files in path
    fidsAll= spm_select('FPListRec',path_nii,'\.nii');
  
    % find dynamic series files, return in a cell array. 
    fid4D =fidsAll(wc_is4D(fidsAll),:);
   
    % Take a weighted mean of all the frames, P character array of the file id
    % mean and all the files used to make it, with the mean file first.
    [~,P]=wc_weighted_mean(fid4D);
    
    % realign frames, this rights a text file rp_*.txt to the pwd with the
    % shift parameters. 
     spm_realign(P);

    
    % get the rigid motion parameters for every frame. rp will be a nx6
    % double array where n is the number of frames in the dynamic pet
    % series plus 1. 
    rp=getShiftParameters(P);
    
    % if this isn't a defining normal motion, check the motion to write to
    % the error file. 
    if opts.doMotion
        wc_check_motion(rp,P,opts)
    end
    
    % delete the files just gunzipped, be careful with this function. 
    wc_delete(path_nii);
   
end 

%------------------------------------------------------------------
% GETSHIFTPARAMETERS: function to get the shift parameters from the
% rp_*.txt file . 
% input--> P, character array put into spm_realign. 
% output--> is a double array containing the translation parameters given by
% rp_*.txt. 
%------------------------------------------------------------------
function C=getShiftParameters(P)
    fidSum=P(1,:);
    [filepath,fileName]=spm_fileparts(fidSum);

    fidParam=[filepath,'/rp_',fileName,'.txt'];
    if exist(fidParam,'file')==0
        error('Cant get shift parameters without first running a realignment.');
    end

    % read in translation information in mm. % take in float16 variables
    C=dlmread(fidParam);
    if ~all(size(C)==[size(P,1) 6])
          error('Didnt read the parameter file correctly, double array should be a n x 6:');
    end

end


    
   



    
