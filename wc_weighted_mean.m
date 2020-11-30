function [V,P]=wc_weighted_mean(fid,frameRates)
% WC_WEIGHTED_MEAN:  computes the weighted mean of dynamic PET series, then
% produces a nifti image of it
% Input: fid: file id of the 4D pet file which a sum is to be taken of.
%           Given in the form of a character vector. 
%        frameRates:A column vector of doubles defining the frame rates
%                   for each frame (in seconds). The numel must be the same as the
%                   number of frames, otherwise, an error will be thrown.
%                   [Default: 'PiB' ~  17 frames; first 5 @ 2mins, 12 @ 5mins]
% 
% Output: V: An struct returned by spm_vol of the newly made weighted image.
%         P: A character array of the file id of the new mean image and
%         all the files from the dynamic pet series used to make it. Mean
%         image is the first one, use for spm_realign. 
%
%  Author:  Bryce Johnson 08132019 version 1.0 
%  Email: joh14192@umn.edu
%  University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 


% check input
if nargin<2
    % default is PiB
    frameRates=zeros(1,17);
    frameRates(1:5)=120; % first 5 frames to 2 minutes 
    frameRates(6:17)=300; % next 12 to 5 minutes 
end

% something failed earlier in the function just return. 
if isempty(fid)
    return
end
    

% check that the nb of frames equals number of frameRates 
dim4=numel(spm_vol(fid));

if numel(frameRates)~=dim4
    error('Frame rates input doesnt match nb of frames in nii file');
end


[filepath,fileName]=fileparts(fid);
if isempty(filepath),filepath=pwd;end
% select the proper file, given by exp
exp=['^',fileName,'\.nii$'];
fidframes=spm_select('ExtFPList',filepath,exp,Inf); % get all frames
fidmean=[filepath,'/mean',fileName,'.nii'];

% if the mean file exists; delete it
if ~exist(fidmean,'file')==0
             delete(fidmean);
end

% get the mean expression for spm_imcalc
meanexp=writeExp(frameRates);

% use spm to do the actual mean average of the image 
V=spm_imcalc(fidframes,fidmean,meanexp);
P=char(fidmean,fidframes);
end 

%------------------------------------------------------------------
% WriteExp: write the expression that spm is going to use to take the
% weighted mean. for spm_imcalc
%------------------------------------------------------------------

function meanexp=writeExp(frameRates)
% write the expression spm is going to use in spm_imcalc: 
meanexp='';
for i=1:numel(frameRates)
    if isempty(meanexp)
        meanexp=['(i1*',num2str(frameRates(i))];
    else
        meanexp=[meanexp,' + ','i',num2str(i),'*',num2str(frameRates(i))];
    end
end
meanexp=[meanexp,')/',num2str(sum(frameRates))];

end 
