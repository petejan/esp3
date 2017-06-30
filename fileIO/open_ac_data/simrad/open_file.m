%% open_file.m
%
% ESP3 main function to open new file(s)
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |file_id| File ID (Required. Valid options: char for a single filename,
% cell for one or several filenames, |0| to open dialog box to prompt user
% for file(s), |1| to open next file in folder or |2| to open previous file
% in folder.
% * |main_figure|: Handle to main ESP3 window (Required).
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% * Could upgrade input variables management to input parser
% * Update if new files format to be supported
% * Not sure why the ~,~ at the beginning?
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2017-03-17: reformatting comment and header for compatibility with publish (Alex Schimel)
% * 2017-03-02: Comments and header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function open_file(~,~,file_id,main_figure)

%%% Grab current layer (files data) and paths
layer = getappdata(main_figure,'Layer');
layers = getappdata(main_figure,'Layers');
app_path = getappdata(main_figure,'App_path');

%%% Check if there are unsaved new bottom and regions
check_saved_bot_reg(main_figure);

%%% Exit if input file was bad
% (put this at beginning and through input parser)
if isempty(file_id)
    return;
end

%%% Get a default path for the file selection dialog box
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

%%% Grab filename(s) to open
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
        
        Filename=cellfun(@(x) fullfile(path_f,x),Filename,'UniformOutput',0);
        
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
        
        
    end
    
end

%%% Exit if still no file at this point (shouldn't be?)
if isempty(Filename)
    return;
end
if isequal(Filename, 0);
    return;
end

%%% Turn filename to cell if still not done at this point (shouldn't be?)
if ~iscell(Filename)
    Filename_tot = {Filename};
else
    Filename_tot = Filename;
end

if ~isempty(layers)
    [old_files,~]=layers.list_files_layers();
    idx_already_open=cellfun(@(x) any(strcmpi(x,old_files)),Filename_tot);
    if any(idx_already_open)
        fprintf('File %s already open in existing layer\n',Filename_tot{idx_already_open});
        Filename_tot(idx_already_open)=[];
    end
end


%%% Get types of files to open
ftype_cell = cell(1,length(Filename_tot));
for ifi = 1:length(Filename_tot)
    ftype_cell{ifi} = get_ftype(Filename_tot{ifi});
end
if isempty(ftype_cell)
    return;
end

%%% Find each ftypes in list to batch process the opening
[ftype_unique,~,ic] = unique(ftype_cell);

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');

%%% File opening section, by type of file
for itype = 1:length(ftype_unique)
    
    % Grab filenames for this ftype
    Filename = Filename_tot(ic==itype);
    ftype = ftype_unique{itype};
    
    % Figure if the files requested to be open are part of a transect that
    % include other files not requested to be opened. This functionality is
    % not available for all types of files
    switch ftype
        case {'EK60','EK80'}
            missing_files = find_survey_data_db(Filename);
            if ~isempty(missing_files)
                % If there are, prompt user if they want them added to the
                % list of files to open
                choice = questdlg(sprintf('It looks like you are trying to open incomplete transects (%.0f missing files)... Do you want load the rest as well?',numel(missing_files)), ...
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
            
        case {'asl','fcv30','dfile'}
            
        otherwise
            for ifi=1:length(Filename)
                fprintf('Unrecognized File type for Filename %s\n',Filename{ifi});
            end
            continue;
            
    end
    
    
    % Open the files. Different behavior per type of file
    switch ftype
        
        case 'fcv30'
            new_layers=[];
            for ifi = 1:length(Filename)
                lays_tmp=open_FCV30_file(Filename{ifi},...
                    'PathToMemmap',app_path.data_temp,'load_bar_comp',load_bar_comp);
                new_layers=[new_layers lays_tmp];
            end
            if isempty(new_layers)
                continue;
            end
            multi_lay_mode=0;
            
        case {'EK60','EK80'}
            
            new_layers=open_EK_file_stdalone(Filename,...
                'PathToMemmap',app_path.data_temp,'LoadEKbot',1,'load_bar_comp',load_bar_comp);
            if isempty(new_layers)
                continue;
            end
            
            
            load_bar_comp.status_bar.setText('Loading Bottom and regions');
            set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(new_layers),'Value',0);
            for i=1:numel(new_layers)
                set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(new_layers),'Value',i);
                try
                    new_layers(i).load_bot_regs();
                catch err
                    disp(err.message);
                    fprintf('Could not load bottom and region for layer %s',list_layers(new_layers(i),'nb_char',80));
                end
            end
            
            load_bar_comp.status_bar.setText('Updating Database with GPS Data');
            new_layers.add_gps_data_to_db();
            
            load_bar_comp.status_bar.setText('Loading Survey Metadata');
            new_layers.load_echo_logbook_db();
            
            load_bar_comp.status_bar.setText('Loading Lines');
            set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(new_layers),'Value',0);
            
            for i=1:length(new_layers)
                set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(new_layers),'Value',i);
                try
                    new_layers(i).add_lines_from_line_xml();
                catch err
                    disp(err.message);
                    laystr=list_layers(new_layers(i),'nb_char',80);
                    fprintf('Could not load lines for layer %s',laystr{1});
                end
            end
            
            multi_lay_mode=-1;
        case 'asl'
            
            new_layers=open_asl_files(Filename,...
                'PathToMemmap',app_path.data_temp,'load_bar_comp',load_bar_comp);
            
            if isempty(new_layers)
                continue;
            end
            load_bar_comp.status_bar.setText('Loading Survey Metadata');
            new_layers.load_echo_logbook_db();
            
            load_bar_comp.status_bar.setText('Loading Bottom and regions');
            set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(new_layers),'Value',0);
            
            for i=1:length(new_layers)
                set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(new_layers),'Value',i);
                try
                    new_layers(i).load_bot_regs();
                catch err
                    disp(err.message);
                    fprintf('Could not load bottom and region for layer %s',list_layers(new_layers(i),'nb_char',80));
                end
            end
            
            multi_lay_mode=0;
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
                continue;
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
                    new_layers=read_crest(Filename,...
                        'PathToMemmap',app_path.data_temp,'CVSCheck',CVSCheck,'CVSroot',app_path.cvs_root);
                case 0
                    new_layers=open_dfile(Filename,'CVSCheck',CVSCheck,'CVSroot',app_path.cvs_root,...
                        'PathToMemmap',app_path.data_temp,'load_bar_comp',load_bar_comp);
            end
            multi_lay_mode=0;
        case 'invalid'
            for ifi=1:length(Filename)
                fprintf('Could not open %s\n',Filename{ifi});
            end
            continue;
        otherwise
            for ifi=1:length(Filename)
                fprintf('Unrecognized File type for Filename %s\n',Filename{ifi});
            end
            continue;
            
    end
    
    
    new_layers=reorder_layers_time(new_layers);
    files_lay=new_layers(1).Filename;
    all_layer=[layers new_layers];
    all_layers_sorted=all_layer.sort_per_survey_data();
    
    load_bar_comp.status_bar.setText('Shuffling layers');
    
    layers_out=[];
    
    for icell=1:length(all_layers_sorted)
        layers_out=[layers_out shuffle_layers(all_layers_sorted{icell},'multi_layer',multi_lay_mode)];
    end
    
    layers=reorder_layers_time(layers_out);
end

%%% TODO: comment
hide_status_bar(main_figure)

if isempty(layers)||~exist('files_lay','var')
    return;
end

[idx,~]=find_layer_idx_files(layers,files_lay);
layer=layers(idx);

setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Layers',layers);



%%% Update display?
loadEcho(main_figure);



end