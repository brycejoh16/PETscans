function badfids=wc_delete(path_file,ext,nb)
%   WC_DELETE: does a delete of all specified ending files 
% returns back a cell array of files it just deleted. 
%
% NOTE:  BE VERY CAREFUL WITH THIS FUNCTION, COULD LEAD TO DELETING OF
% USEFUL DATA 
% 
%INPUT:
%       path_file: directory to which to delete file
%       ext: file extensions which to delete 
%           [default: '.html','.nii','.tar','.txt','.mat']
%       nb: number of files allowed to delete [default:25] , safety check
%       so you don't loose everything. 
% output:
%        badfids : cell array of files just deleted
% 
% Author:  Bryce Johnson 08202019 version 1.0
% email:  joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 
if nargin<3,nb=25;end
if nargin<2,ext={'.html','.nii','.tar','.txt','.mat'};end
fids=wc_getFids(path_file);
if strcmp(ext,'dcm')
    badfids=fids(wc_isdicom(fids));
else 
    badfids=fids(endsWith(fids,ext));
end
if numel(badfids)<nb
delete(badfids{:});
end

end