function wc_master_qc(path_dicom_studies,path_nii,opts)
% WC_MASTER_QC: this is the master script to perform all quality control
% checks across studies. Make sure you have the proper dicom file tree for
% your dicom studies as shown in wc_get_study_dir. 
% Note: 
% error_path.mat should also contain a character vector with one variable name
% error_path with where the files that contain errors should be written. 
% Prior to normal motion should be defined by  xyzrpy.mat
% containing  a variable xyzrpy defined by wc_def_norm_movement
%
% ********************** IMPORTANT ******************************** 
% Both error_path.mat and xyzrpy.mat must be on the MATLAB path unless
% included in opts (see below)
% *****************************************************************
%
% Input: path_dicom_studies :  path to all the dicom studies, has to follow the
%        same file tree as specified by wc_get_study_dir()
%        path_nii :  directory to save the nii studies to. 
%        opts: a structure containing flags on what qc processes to do and
%        paths to .mat files if necessary. 
%           
%           ->opts.doMotion: boolean TF saying whether to do a motion
%           correction. [default: true]
%           ->opts.stdev: the amount of standard deviation that is acceptable
%           from normal parameters without flagging. [default: 3]
%           ->opts.dosort: boolean saying whether the function wc_dicom_petct_sorter4_0, 
%           to sort the metadata should be called, as it may contain
%           bugs and errors. [default: false]
%           ->opts.headerSort: how much of header to display, look to wc_dicom_petct_sorter4_0
%           for options. [default: no inputs which is defaults in wc_dicom_petct_sorter4_0]
%           ->opts.error_path: path to error_path.mat file [default: will
%           look to matlab path]
%           ->opts.xyzrpy_path: path to xyzrpy .mat file,[default: will
%           just look to matlab path]
%           ->opts.doAmideReslice: T/F boolean on whether to reslice dicom images to
%            overlay with nifti in amide. Not recommended if dont want to change
%            original dicom images. However, code in wc_dicom2origin could be
%            improved to account for this. [default:false]
%           
%
% Output: csv file : files which can't perform the quality check are
% written to a csv file specified by error_path.mat
% 
% Author:  Bryce Johnson 08202019 version 1.0
% email:  joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 


% check input
if nargin<3
    opts=struct('stdev',3,'headerSort','default','doMotion',true,'dosort',false,...
        'doAmideReslice',false);
else
    % check the opts field
    if ~isfield(opts,'stdev'),opts.stdev=3;end
    if ~isfield(opts,'dosort'),opts.dosort=false;end
    if ~isfield(opts,'doMotion'),opts.doMotion=true;end
    if ~isfield(opts,'headerSort'),opts.headerSort='default';end
    if ~isfield(opts,'doAmideReslice'),opts.doAmideReslice=false;end
end

% check xyzrpy.mat file and error_path.mat file 
wc_check_xyzrpy(opts);
wc_check_error_path(opts);


% get all the dicom study directory ids 
dcmStudies=wc_get_study_dir(path_dicom_studies);

% peform sort of dicm metadata 
% this needs more testing before it can be included.
if opts.dosort
 dcmsort(dcmStudies,opts);
end

if opts.doMotion
    % make nifti files, then get all nii study directory ids. 
    niiStudies=makeNii(dcmStudies,path_nii,opts);
    
    % perform the motion correction check
    motionCorr(niiStudies,opts);
end

end

%------------------------------------------------------------------
% makeNii: makes nifti files out of dicom studies. 
%------------------------------------------------------------------
function niiStudies=makeNii(dcmStudies,path_nii,opts)

for i=1:numel(dcmStudies)
    try 
        wc_dicom2nii(dcmStudies{i},path_nii,opts.doAmideReslice);
    catch errorStruct
        wc_write2error(dcmStudies{i},errorStruct,'Wasnt able to convert following dicom study to nii: ');
        continue 
    end 
end

niiStudies=wc_get_study_dir(path_nii);



end

%------------------------------------------------------------------
% motionCorr: makes nifti files out of dicom studies. 
%------------------------------------------------------------------
function motionCorr(niiStudies,opts)
    for i=1:numel(niiStudies)
        try 
            wc_motion_corr_4D(niiStudies{i},opts);
        catch errorStruct
            wc_write2error(niiStudies{i},errorStruct,'Error performing motion correciton to following nii study: ');
            continue 
        end 
    end
end

%------------------------------------------------------------------
% dcmsort: sort header information. Produce csv files of all the header
% information. 
%------------------------------------------------------------------
function dcmsort(dcmStudies,opts)
    for i=1:numel(dcmStudies)
        try 
            wc_dicom_petct_sorter4_0(dcmStudies{i},opts.headerSort);
        catch errorStruct
            % if there is an error write it. 
            wc_write2error(dcmStudies{i},errorStruct,'Error performing sort to following dcm study: ');
            continue 
        end 
    end
end




