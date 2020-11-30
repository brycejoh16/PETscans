function wc_check_error_path(opts)
% WC_CHECK_ERROR_PATH: a function to check the error path specified by
% error_path.mat. error_path.mat must contain a single variable error_path
% which has the path to where to store the error catch csv file from
% wc_write2error. 
% Inputs: opts: either a struct containting a field name 'error_path' which
%         has the directory to which to store the error_path.mat file to, or a
%         character vector containing the directory. If not input it will
%         just look at the matlab path. [default: will look to matlab path]
% 
% Author:  Bryce Johnson 08202019 version 2.0
% email:  joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 
 
%check input 
if nargin<1
    filepath_error='error_path.mat';
elseif isstruct(opts) && isfield(opts,'error_path')
    filepath_error=[opts.error_path,'/error_path.mat'];
elseif ischar(opts)
     filepath_error=[opts,'/error_path.mat'];
else 
    filepath_error='error_path.mat';
end

load(filepath_error,'error_path');
if isempty(error_path)
    error('Make sure to specify error file path');
end

end