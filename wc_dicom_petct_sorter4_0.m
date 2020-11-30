function varargout=wc_dicom_petct_sorter4_0(path_dicom,varargin)
%% This function sorts dicom data for PET/CT studies conducted for the UW
% ADRC. 
% ************************ WARNING *********************************
% This code is hard to debug , and prone to errors due to the constantly
% changing dicom header. Use this function with caution as it will commonly
% throw errors.
% ******************************************************************
%
% Code written by Tobey Betthauser UW-Madison 20190207
% Version Tracker---
%   TJB 20190207 - Inital Version
%   BCJ 20190531 - Adopted Version -
%                -> changes output csv to a summary of field names  
%                from different series types. 
%                -> Must be run with matlab function NestedStruct2table.m
%                and cell2csv.
%
% 
% Usage: fid_csv = dicom_petct_sorter(path_dicom)
% 
% Required Input Arguments:
% path_dicom - string containing the directory with the dicom files
% 
% Optional Input arguments:
% path_goodfields - string containing the directory with choosen fields to
% display in a csv file
% 
% USAGE: 
% DICOM_PETCT_SORTER(path_dicom) - displays the default header information,
% shown below by goodfields cell array to csv file. 
% DICOM_PETCT_SORTER(path_dicom,'all') - displays all header data to a .csv 
% file.
% DICOM_PETCT_SORTER(path_dicom,path_goodfields) - displays chosen 
% fieldNames from path_goodfields .csv file
% 
% 
% Optional Output Arguments:
% fid_csv - a string containing the full path to the generated .csv file
%
% Author:  Bryce Johnson 08202019 version 4.0
% email: joh14192@umn.edu
% University of Wisconsin 
% __________________________________________________________________
%       Waismann Center , Aug 2019 


%% checking input parameters
 
switch nargin
    case 1
        % only dicom path 
        if ~ischar(path_dicom)
            disp('not a valid DICOM path')
            return 
        end 
        % default fields that will be printed
        goodfields={'Filename','ImageType','Modality','StudyInstanceUID','SeriesInstanceUID',...
            'SeriesNumber', 'SeriesDescription','NumberOfTimeSlices',...
            'RadiopharmaceuticalInformationSequence_Item_1_Radiopharmaceutical',...
            'NumberOfSlices'};
        
    case 2
        if strcmp(varargin{1},'all')
            goodfields={}; % print all fields from every series
        elseif strcmp(varargin{1},'default')
                goodfields={'Filename','ImageType','Modality','StudyInstanceUID','SeriesInstanceUID',...
            'SeriesNumber', 'SeriesDescription','NumberOfTimeSlices',...
            'RadiopharmaceuticalInformationSequence_Item_1_Radiopharmaceutical',...
            'NumberOfSlices'};
        elseif ~exist(varargin{1},'file')==2
            error(['Could not open file: ',varargin{1}]);  

        else
            %opening csv file to read in the fields that want to print
            fileID=fopen(varargin{1},'r','n','UTF-8');
            if fileID==-1
                error('Cannot open %s',varargin{1})
            end 
            goodfields=textscan(fileID,'%s','Delimiter',',','CommentStyle','%');
            goodfields=goodfields{1}; 
            fclose(fileID);
            if ~contains(goodfields,'SeriesInstanceUID')
                error('Must contain seriesUID')
            end 
        end
        
    otherwise
        error('Wrong number of inputs')
end 

%% Read in dicom fields for all dicom files, output 
% the contents of each field to a cell array ->C

% unzip all file ids in the dicom folder and subdirectories.
fids=wc_getdirfids(path_dicom,'dicom');

% take in all header info
disp('Reading Dicom Files')
row=0; % max filled row
col=0; % max filled column
startTime=cputime;
for j=1:numel(fids)
 
    d=dicominfo(fids{j}); % reading in DICOM info 
    T=NestedStruct2table(d); % returns a cell array of all dicom info (including nested structures)
    fieldName=T{1,:}; 
    contents=T{2,:};  

    if j==1 && row==0 && col==0  % case of an empty cell array 
        C{numel(fids)+1,(3*numel(fieldName))}=[]; % pre-allocation of memory for speed
        row=2;
    elseif (col+numel(fieldName))>=numel(C(1,:))
        C{numel(fids)+1,(numel(fieldName)+col)}=[]; % expand array if neccessary
        row=row+1; 
    else 
        row=row+1; % new file id, so new row. 
    end 

    for i=1:numel(fieldName)
        badfields={'Private','DataSetTrailingPadding'};
        if contains(fieldName{i},badfields)
            % do nothing
        else 
            row_contents=contents(:,i); % contents of each row from field
            if ~iscell(row_contents)
                    row_contents=num2cell(row_contents); %if its a number turn it into a cell
            end 
            
            % finding the number of elements that are not null in a
            % fieldName
            notNull=row_contents(~cellfun('isempty',contents(:,i)));
            
            % looping through all the elements in a given fieldName
            for k=1:numel(notNull)
                
                %%% error checking for csv output
               if ~isa(row_contents{k},'str')
                        row_contents{k}=num2str(row_contents{k});
               end 
                
               badchar={',',newline}; % filter out any newlines or commas
               if any(contains(row_contents{k},badchar))
                    row_contents{k}=regexprep(row_contents{k},'\s+',' ');
                    row_contents{k}=replace(row_contents{k},',',' ');
               end 

               
               
                % make a temp Name for each fieldName if multiple elements
                if numel(notNull)>1
                    tempFN=[fieldName{i},'_',num2str(k)];
                else 
                    tempFN=fieldName{i};
                end 

                
               % if its already in out cell array then add it to that
               % column
                if any(strcmp(C(1,:),tempFN))
                    [~,index_col]=find(strcmp(C(1,:),tempFN));
                    C{row,index_col}=row_contents{k};
                else 
                    % else make a new column at the end to put contents
                    % into
                    col=col+1;
                    C{1,col}=tempFN;
                    C{row,col}=row_contents{k};
                end 
            end
        end 
    end
end
endTime=num2str(cputime-startTime);

%% finding the unique series UID's
% filtering out extra null characters from cell array
fieldName=C(1,:);
fieldName=fieldName(~cellfun('isempty',fieldName));
nbOfFieldNames=numel(fieldName);
C=C(:,1:nbOfFieldNames);
contents=C(2:end,1:nbOfFieldNames);
disp(['Took in ',num2str(size(contents,1)),' dicom files in ',endTime,' seconds'])

disp('Finding unique serial numbers')
[~,series_nb_col]=find(strcmp(fieldName,'SeriesInstanceUID'));
[~,unique_series_col]=unique(contents(1:end,series_nb_col));
summary=contents(unique_series_col,:);

%% checking for errors in extraction for each series 
% if the a dicom file doesn't produce a fieldName but the
% rest do in a series, will give a warning
disp('Making sure all data was acquired')

clear i j
petFields={};
[~,series_modality_col]=find(strcmp(fieldName,'Modality'));
[~,series_frames_col]=find(strcmp(fieldName,'NumberOfTimeSlices'));
[~,series_descrip_col]=find(strcmp(fieldName,'SeriesDescription'));
for i=1:numel(summary(:,1))
    
    % finding all data in one series
    series=filter_petct(contents,fieldName,summary(i,series_nb_col),series_nb_col);
    for j=1:numel(series(1,:))
        fieldAttributes=series(:,j); % all data in a fieldName
        
        notNull_field_Att=fieldAttributes(~cellfun('isempty',fieldAttributes));

        if isempty(notNull_field_Att)
            % do nothing 
        elseif  ~(numel(fieldAttributes)==numel(notNull_field_Att)) 
            % display warning message if some data isn't transmitted
            % through
            warning('Series: "%s" has dicom files which dont produce fieldName: "%s"',...
            series{1,series_descrip_col},fieldName{j});
        elseif   numel(unique(fieldAttributes))>1  && ...
                   strcmp(series{1,series_modality_col},'PT') &&...
                   ~any(ismember(petFields,fieldName(j))) &&... 
                   any(~cellfun(@isempty,series(:,series_frames_col)))
             % it must be a 4D time series 
             % if unquie data put it into petFields cell array. 
            petFields=[petFields,fieldName(j)];
%             if strcmp(fieldName(j),'FileModDate')
%                 keyboard
%             end
               
        else
            % do nothing 
        end        
    end
end

%% finding unique PET 4D data 
% filter out all the series that have null fields as filter
descriptionFields={'SeriesDescription','NumberOfTimeSlices'};
petFields=[petFields,descriptionFields];

ids_pet=ismember(contents(:,series_modality_col),'PT') &... 
    ~cellfun('isempty',contents(:,series_frames_col));
ids_petFields=ismember(fieldName,petFields);
petFields=fieldName(ids_petFields);
petTitle=cell(3,numel(petFields));
petTitle{1,1}='Shows changing 4D PET field Names';
petTitle(2,1:numel(descriptionFields)+1)=[{'Fields shown for convenience: (Not Changing)'},descriptionFields];
petData=[petTitle;petFields;contents(ids_pet,ids_petFields)];

disp('Writing 4D PET .csv file');
fid_pet=[path_dicom,'/pet4Dsort.csv'];
print_csv(fid_pet,petData);

%% finding which series attributes are local to a single/multiple series, 
% or which attributes are the same in every series 

 series_sorter(path_dicom,fieldName,summary);

%%keeping only specified good-fields and printing summary

[summary,fieldName]=filter_petct(summary,fieldName,goodfields);

C=[fieldName;summary];

disp('Writing dicomsort.csv file');
fid_csv = [path_dicom,'/dicomsort.csv'];
print_csv(fid_csv,C);
%unzipRezip(path_dicom,false);
varargout{1}=fid_csv;
end 

%%

function [contents,fieldName]=filter_petct(contents,fieldName,varargin)
% FILTER_PETCT filters a pet_ct cell array, returns filtered cell array
    % FILTER_PETCT(content,fieldName,fields_col) filters the column fields from an array
    % FILTER_PETCT(content,fieldName,fields_row,row_filter_coloumn) filters fields 
    % from the rows of a cell array. Must specify the column you want to
    % filter 
    % FILTER_PETCT(content,fieldName,fields_col,fields_row,row_filter_coloumn)
    % filters the rows and column fields from 
    % as cell array.

% check input 
switch nargin 
    case 3
            if iscell(varargin{1})
                fields_col=varargin{1};
                fields_row={};
            else 
                error("Last input must be a cell array to filter columns");
            end 
    case 4
        if isnumeric(varargin{2})
            fields_row=varargin{1};
            row_filter_col=varargin{2};
            fields_col={};
        else 
            error("Last input must be an index of column to filter");
        end 
    case 5 
        if isnumeric(varargin{3})
            fields_col=varargin{1};
            fields_row=varargin{2};
            row_filter_col=varargin{3};
        else
            error("Last input must be an index of column to filter");
        end 
        
    otherwise 
        error("Input arguments incorrect");
end 

% filter rows 
if ~isempty(fields_row)
    ids_row=ismember(contents(:,row_filter_col),fields_row);
    contents=contents(ids_row,:);
end 


% filter columns 
if ~isempty(fields_col)
    ids_col=ismember(fieldName,fields_col);
    contents=contents(:,ids_col);
    fieldName=fieldName(ids_col);
end 


end 

%%
function print_csv(fid_csv,C,varargin)
% PRINT_CSV(fid_csv,C) prints out a .csv file of cell array (C) to the 
% location specified by the fid_csv. Function will delete file if it
% already exists in the path specified by fid_csv
% PRINT_CSV(fid_csv,C,'append') will append the cell array to the .csv
% file

% check input 
switch nargin
    case 2 
        if ~endsWith(fid_csv,'.csv')
            error("File ID is not a csv file.");
        elseif exist(fid_csv,'file')==2
            delete(fid_csv);
            disp(['Deleted Previous Sort: ',fid_csv])
        end 
    case 3
        if ~endsWith(fid_csv,'.csv')
            error("File ID is not a csv file.");
        elseif ~strcmp(varargin{1},'append')
            error('Command: %s, unknown',varargin{1});
        end       
end 



if exist('cell2csv','file')==2
    cell2csv(fid_csv,C,','); % not a local function
    
else  % use this if no cell2csv.m file, but likely more error prone
    file_csv = fopen(fid_csv,'a+');
    out=[repmat('%s, ',1,nbOfFieldNames-1),'%s\n'];
    fprintf(file_csv,out,C{1,:});
    for i=1:numel(C(:,1))-1
        fprintf(file_csv,out,C{i+1:end:numel(C(:,1)),:});
    end 
    fclose(file_csv);
end 



end

%%
function series_sorter(path_dicom,fieldName,summary)
% Finds local fields local to all series and then prints those fields with
% their corresponding output to a csv file called 'commonfieldsort.csv'. 
% finding which series attributes are local to a single/multiple series, 
% or which attributes are the same in every series 

[~,series_nb_col]=find(strcmp(fieldName,'SeriesInstanceUID'));
[~,series_descrip_col]=find(strcmp(fieldName,'SeriesDescription'));

uFN{numel(fieldName)+2,size(summary,1)}=[];
uFN(1,:)=summary(:,series_nb_col);
uFN(2,:)=summary(:,series_descrip_col);
localFields={};
for i=1:numel(fieldName)
    column=summary(:,i);
    notNullColumn=column(~cellfun('isempty',column));
    if numel(notNullColumn) == numel(column)
        localFields=[localFields,fieldName(i)]; % all series have the 
        % same contents inside a fieldName
    else %numel(notNullColumn)==1 % uncomment that if you only want fieldNames 
        % that are unique to one series. 
            idx_arrray=1:numel(column);
            idx_arrray=idx_arrray(~cellfun('isempty',column));

            for j=1:numel(idx_arrray)
                rowFN=find(cellfun(@isempty,uFN(:,idx_arrray(j))),1,'first');
                uFN(rowFN,idx_arrray(j))=fieldName(i);
            end
    end
end


% finding local fields common to all series 
% local fields 
[localSummary,localFields]=filter_petct(summary,fieldName,localFields);
fid_summarySort=[path_dicom,'/commonfieldsort.csv'];
titleLocalFields=cell(2,numel(localFields));
titleLocalFields{1}='Fields Common to all Series';
print_csv(fid_summarySort,[titleLocalFields;localFields;localSummary]);

seriesOutput=cell(1,numel(fieldName)+1);
seriesOutput{1}='Fields Not Common to all Series';

for i=1:size(uFN,2) % loop over all the columns
    seriesUID=uFN(1,i);
    seriesDescription=uFN{2,i};
    seriesFields=uFN(3:end,i);
    seriesFields=seriesFields(~cellfun('isempty',seriesFields));
    if ~isempty(seriesFields)
        [seriesContent,seriesFields]= filter_petct(summary,fieldName,seriesFields,seriesUID,... 
            series_nb_col);
        seriesTitle=cell(3,numel(fieldName)+1);
        seriesTitle{3,1}=['Series: ',seriesDescription];
        seriesContent{1,numel(fieldName)+1}=[];
        seriesFields{1,numel(fieldName)+1}=[];
        seriesOutput=[seriesOutput;seriesTitle;seriesFields;seriesContent];
    end 
end 
seriesOutput=seriesOutput(:,any(~cellfun(@isempty,seriesOutput)));
fid_series=[path_dicom,'/series_sort.csv'];
print_csv(fid_series,seriesOutput);


end 
