function open_file(~,~,file_id,main_figure)
% open_file(~,~,file_id,main_figure)
%
% DESCRIPTION
%
% Main function to open new file(s)
%
% USE
%
% [A bit more detailed description of how to use the function. DELETE THIS LINE IF UNUSED]
%
% PROCESSING SUMMARY
%
% - [Bullet point list summary of the steps in the processing.]
% - [DELETE THESE LINES IF UNUSED]
%
% INPUT VARIABLES
%
% - file_id (required): Valid options:
%   - char: filename
%   - cell: filename(s)
%   - 0: open dialog box to prompt user for file(s)
%   - 1: open next file in folder
%   - 1: open previous file in folder
% - main_figure (required): ESP3 main figure
%
% RESEARCH NOTES
%
% - Could upgrade input variables management to input parser
% - Update if new files format to be supported
% - Not sure why the ~,~ at the beginning?
%
% NEW FEATURES
%
% 2017-03-02: Comments and header Alex
%
%%%
% Yoann Ladroit, NIWA.
%%%

% Grab current layer (files data) and paths
layer = getappdata(main_figure,'Layer');
app_path = getappdata(main_figure,'App_path');

% About to open a new file so check if there are unsaved new bottom and
% regions 
check_saved_bot_reg(main_figure);

% Exit if input file was bad (put this at beginning and through input
% parser)
if isempty(file_id)
    return;
end

% Get a default path for the file selection dialog box
if ~isempty(layer)
    [path_lay,~] = layer.get_path_files();
    if ~isempty(path_lay)
        % if file(s) already loaded, same path as first one in list
        file_path = path_lay{1};
    else
        % config default path if none
        file_path = app_path.data;
    end
else
    % config default path if none
    file_path = app_path.data;
end

% Grab filename(s) to open
if iscell(file_id) || ischar(file_id) % if input variable is the filename(s) itself
    
    Filename = file_id;
    
else
    
    if file_id == 0 % if requesting opening a selection dialog box
        
        % dialog box
        [Filename,path_f] = uigetfile( {fullfile(file_path,'*.raw;d*;*A;*.lst')}, 'Pick a raw/crest/asl/fcv30 file','MultiSelect','on');
        
        % nothing opened
        if isempty(Filename)
            return;
        end
        
        % single file is char. Turn to cell
        if ~iscell(Filename)
            if (Filename==0)
                return;
            end
            Filename = {Filename};
        end
        
        % keep only supported files, exit if none
        idx_keep =~ cellfun(@isempty,regexp(Filename(:),'(A$|raw$|lst$|^d.*\d$)'));
        Filename = Filename(idx_keep);
        if isempty(Filename)
            return;
        end
        
        % add path to filenames
        for ic = 1:length(Filename)
            Filename{ic} = fullfile(path_f,Filename{ic});
        end
        
    elseif file_id == 1 % if requesting to open next file in folder
        
        % Grab filename(s) in current layer
        if ~isempty(layer)
            [~,Filename] = layer.get_path_files();
        else
            return;
        end
        
        % find all files in path      
        f = dir(file_path);
        file_list = ({f(~cellfun(@isempty,regexp({f.name},'(A$|raw$|lst$|^d.*\d$)'))).name}');
        
        % find the next file in folder after current file
        if ~isempty(file_list)
            i = 1;
            file_diff = 0;
            while i<size(file_list,1) && file_diff==0
                file_diff = strcmp(file_list{i},Filename{end});
                i = i+1;
            end
            if file_diff
                Filename = fullfile(file_path,file_list{i});
            else
                Filename = [];
            end
        else
            return;
        end
        
    elseif file_id == 2 % if requesting to open previous file in folder
        
        % Grab filename(s) in current layer
        if ~isempty(layer)
            [~,Filename] = layer.get_path_files();
        else
            return;
        end
        
        % Grab filenames in current layer
        f = dir(file_path);
        file_list = ({f(~cellfun(@isempty,regexp({f.name},'(A$|raw$|lst$|^d.*\d$)'))).name}');
        
        % find the previous file in folder before file currently displayed
        if ~isempty(file_list)
            i = size(file_list,1);
            file_diff = 0;
            while i>1 && file_diff==0
                file_diff = strcmp(file_list{i},Filename{1});
                i = i-1;
            end
            if file_diff
                Filename = fullfile(file_path,file_list{i});
            else
                Filename = [];
            end
            
        end
        
    elseif ischar(file_id) % this case might be already taken care of?
        
        Filename = fileID;
        
        if isempty(Filename)
            return;
        end
        
    end
    
end

% Exit if still no file at this point (shouldn't be?)
if isempty(Filename)
    return;
end
if isequal(Filename, 0)
    return;
end

% Turn filename to cell if still not done at this point (shouldn't be?)
if ~iscell(Filename)
    Filename_tot = {Filename};
else
    Filename_tot = Filename;
end

% Get types of files to open
ftype_cell = cell(1,length(Filename_tot));
for ifi = 1:length(Filename_tot)
    ftype_cell{ifi} = get_ftype(Filename_tot{ifi});
end

% Not sure why we need to do this here as layer was not changed
setappdata(main_figure,'Layer',layer);

% Find each ftypes in list to batch process the opening
[ftype_unique,~,ic] = unique(ftype_cell);

% File opening section, by type of file
for itype = 1:length(ftype_unique)
    
    % Grab filenames for this ftype
    Filename = Filename_tot(ic==itype);
    ftype = ftype_unique{itype};
    
    % ?
    enabled_obj = findobj(main_figure,'Enable','on');
    set(enabled_obj,'Enable','off');
    
    % Figure if the files requested to be open are part of a transect that
    % include other files not requested to be opened. This functionality is
    % not available for all types of files
    switch ftype
        case {'EK60','EK80','dfile'}
            missing_files = find_survey_data_db(Filename);
            if ~isempty(missing_files)
                % If there are, prompt user if they want them added to the
                % list of files to open
                choice = questdlg('It looks like you are trying to open incomplete transects... Do you want load the rest as well?', ...
                    'Incomplete',... % title bar
                    'Yes','No',...   % buttons
                    'Yes');          % default choice
                switch choice
                    case 'Yes'
                        Filename = union(Filename,missing_files);
                    case 'No'
                    otherwise
                        return;
                end
            end
        otherwise
            return; 
    end
    
    % Load all pings by default
    ping_start = 1;
    ping_end = Inf;
    
    % Open the files. Different behavior per type of file
    switch ftype
        
        case 'fcv30'
            
            for ifi = 1:length(Filename)
                open_FCV30_file(main_figure,Filename{ifi});
            end
            
        case {'EK60','EK80'}
            
            open_raw_file(main_figure,Filename,[],ping_start,ping_end);
            
        case 'asl'
            
            open_asl_files(main_figure,Filename);
            
        case 'dfile'
            
            % Prompt user on opening raw or original and handle the answer
            choice = questdlg('Do you want to open associated Raw File or original d-file?', ...
                'd-file/raw_file',...    % title bar
                'd-file','raw file', ... % buttons
                'd-file');               % default choice
            switch choice
                case 'raw file'
                    dfile = 0;
                case 'd-file'
                    dfile = 1;
            end
            if isempty(choice)
                return;
            end
            
            % Prompt user to load bottom and regions and handle the answer
            choice = questdlg('Do you want to load associated CVS Bottom and Region?', ...
                'Bottom/Region',... % title bar
                'Yes','No', ...     % buttons
                'No');              % default choice
            switch choice
                case 'Yes'
                    CVSCheck = 1;
                case 'No'
                    CVSCheck = 0;
            end
            if isempty(choice)
                CVSCheck = 0;
            end
            
            % Open the files in chosen format
            switch dfile
                case 1
                    open_dfile_crest(main_figure,Filename,CVSCheck);
                case 0
                    open_dfile(main_figure,Filename,CVSCheck);
            end
            
        otherwise
            
            return;
            
    end
end

%?
set(enabled_obj,'Enable','on');

%?
hide_status_bar(main_figure);

% Update display?
loadEcho(main_figure);



end