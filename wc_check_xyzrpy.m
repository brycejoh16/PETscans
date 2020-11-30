function xyzrpy=wc_check_xyzrpy(opts)
% WC_CHECK_XYZRPY: checks the normal motion parameters to see if they are
% feasible values. Also defines how many standards of deviation 
% the xyzrpy can be. xyzrpy.mat must also be on the matlab path. 
% Input: opts: a struct definng the possible options for error checking
%                   ->opts.nb: number of acceptable studies to for defining
%                   normal parameters [default: 10]
%                   ->opts.stdev: number of standards of deviations the
%                   rotation parameters can be before writing to the error
%                   file. [default: 3]
%                   ->opts.percent: percent of the rigid motion parameters
%                   that the mean can be from zero, [default: 10]
%                   ->opts.xyzrpy_path: path to the xyzrpy.mat file, if not
%                   specified file must be on matlab path. 
% output: xyzrpy:  1x6 double array of the accepted standard deviation for each
%           parameter 
% __________________________________________________________________
% Note: xyzrpy.mat must contain 3 parameters in order to check the
% feasibility of the normal motion values : 
% 
%           1.) xyzrpy: 1x6 double array of the standard deviation for each
%           parameter
%           2.) meanxyzrpy: 1x6 double array of the mean for each
%           parameter, which must be reasonably close to zero. [default: within 10%
%           to zero of the standard of deviation for that parameter 
%           if not it will throw an error]
%`          3.) nbOfStudies:  and integer saying how many studies were
%           used to define normal motion.  [default:Must be greater than 10, or will
%           throw an error. ]
% __________________________________________________________________
%
% Author:  Bryce Johnson 08202019 version 1.0
% email: joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 


%check input
if nargin<1
    opts=struct('stdev',3,'nb',10,'percent',10);
else
    % check the opts field
    if ~isfield(opts,'nb'),opts.nb=10;end
    if ~isfield(opts,'stdev'),opts.stdev=3;end
    if ~isfield(opts,'percent'),opts.percent=10;end
end

if isfield(opts,'xyzrpy_path')
        filepath_xyzrpy=[opts.xyzrpy_path,'/xyzrpy.mat'];
else
        filepath_xyzrpy='xyzrpy.mat';
end

load(filepath_xyzrpy,'xyzrpy','meanxyzrpy','nbOfStudies');
if isempty(xyzrpy) || isempty(meanxyzrpy) || isempty(nbOfStudies)
    error(['Didnt define xyzrpy.mat properly. Make sure to include: ',newline,...
        '1.) xyzrpy: 1x6 double array of the standard deviation for each',newline,...
            'parameter',newline,...
            '2.) meanxyzrpy: 1x6 double array of the mean for each',newline,...
            'parameter, which must be reasonably close to zero. (default :within 10%',newline,...
            'to zero of the standard of deviation for that parameter) ',newline,...
            'if not it will throw an error',newline,...
           '3.) nbOfStudies:  and integer saying how many studies were',newline,...
            'used to define normal motion.  Must be greater than opts.nb, or will',newline,...
            'throw an error. '])
end 

if nbOfStudies<opts.nb
    error('nbOfStudies not great enough');
end


opts.percent=opts.percent/100;
% if the mean is greater than a percentage of the rigid motion parameters.
% throw an error. 
if any((xyzrpy.*opts.percent)<abs(meanxyzrpy))
    error(['Mean value not low enough, it should fluctuate around zero, perhaps retry defining',... 
        'the normal motion parameters']);
end

xyzrpy=xyzrpy.*opts.stdev;

end