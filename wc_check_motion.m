function wc_check_motion(rp,P,opts)
% WC_CHECK_MOTION: Will take in the rigid motion parameters from a single
% dynamic pet study, check them against the normal defined motion parameters
% from xyzrpy.mat, and then flag any frames that have more than the
% accepted amount of motion. 
%
% Inputs:
%          rp: nx6 double array with rigid motion parameters produced by
%          spm_realign from wc_motion_corr_4D. 
%          P: a character array of spm file ids(spm_select). See
%          wc_weighted_mean for example. 
%          opts: a struct definng the possible options for error checking
%                   opts.nb: number of acceptable studies to for defining
%                   normal parameters [default: 10]
%                   opts.stdev: number of standards of deviations the
%                   rotation parameters can be before writing to the error
%                   file. [default: 1]
%                   opts.percent: percent of the rigid motion parameters
%                   that the mean can be from zero, [default: 10] 
%                   opts.xyzrpy_path: path to xyzrpy .mat file,[default: will
%                   just look to matlab path]
%
% Outputs: csv file produced by wc_write2error that flags down which frames
% have larger than the accepted amount of motion. 
%       
%
% Author:  Bryce Johnson 08202019 version 1.0
% email:  joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 

% check input 

if size(rp,1)~=size(P,1)
    error(['Error in file,',mfilename,' :',newline,...
        'The length of your rotation parameters,',num2str(size(rp,1)),...
        ',doesnt match the number of files from your character array P,',...
        num2str(size(P,1))])
end

% check the parameters from xyzrpy.mat using opts structure, using default
% for opts in wc_check_xyzrpy;
if nargin<3
    xyzrpy=wc_check_xyzrpy;
else 
    xyzrpy=wc_check_xyzrpy(opts);
end
% check the motion and write to an error file if problems exist. 
checkMotion(xyzrpy,rp,P);



end

function checkMotion(xyzrpy,rp,P)
% possibly find a way to identify where the error occured. 
% C={'x,','y,','z,','roll,','pitch,','yaw,'};
l=(abs(rp)>xyzrpy);
P=P(any(l,2),:);
if ~isempty(P)
    % then there was a bad motion file, write to error file
    wc_write2error(P,'There was motion detected in the following frames,Frame ');

end

end