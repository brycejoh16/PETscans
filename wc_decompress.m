function wc_decompress(path_file,nb,fids)
%  WC_DECOMPRESS:decompresses files which are tarred or gzipped.
%  INPUTS: path_file : the path to where the files are located [default:pwd]
%          nb:  the nb of files that can can be gunzipped, [default: 6]
%          fids: instead of using wc_getFids(), specify the files to decompress. 
%
%
% Author:  Bryce Johnson 08202019 version 1.0
% email:  joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 

% check input
    if nargin<3,fids=wc_getFids(path_file);end
    if nargin<2,nb=6;end
    if nargin<1,path_file=pwd;end
    fidone={};
    % while there are still files that need to be decompressed
    while any(endsWith(fids,{'.tar','.tgz','.bz2','.gz'}))
        
        % find the files that need to be untarred or gunzipped.
        istar=endsWith(fids,{'.tar','.tgz'});
        isbz2=endsWith(fids,{'.bz2','.gz'}); 
        
        % re-inizilize from last while loop iteration
        fids_bz2={};fids_tar={};
        
        % if there are any files to be gunzipped, gunzip them. 
        if any(isbz2)
            
            % the files that need to be gunzipped in a cell array. 
            fids_bz2=fids(isbz2);
            
            % if the files that have to be gunzipped is greater than the
            % allowed nb value, throw an error. 
            if numel(fids_bz2)>nb
                error(['Looks as though you are trying to gunzip more than ',...
                    num2str(nb),' files. This is done to save disk from being ', newline,...
                    'overloaded. Use Inf or a larger number if you are confident this is an okay operation',newline,...
                    'For more information go to script: ', mfilename]);
            end
            
            % now gunzip the files. 
            for i=1:numel(fids_bz2)
                gunzip(fids_bz2{i});
            % system(['bzip2 -df ',fids_bz2{i}]); 
            end
            
        end 
        
        % tar doesnt save disk space so we can untar as much as we want. 
        if any(istar)
            fids_tar=fids(istar);
            [filepaths_tar]=cellfun(@(x) fileparts(x),fids_tar,'uni',false);
            for i=1:numel(fids_tar)
                 system(['tar -xf ',fids_tar{i}, ' -C ',filepaths_tar{i}]);
                 
            end 
        end
        fidone=[fidone;fids_tar;fids_bz2];
        fids=wc_getFids(path_file);
        fids=fids(~ismember(fids,fidone));
    end
    
end