%% process_surveys.m
%
% Loads and runs a script file, and saves the results in output file
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |input_variable_1|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |output_variable_1|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-11-16: more code cleanup and commenting (Alex Schimel)
% * 2017-07-05: started code cleanup and comment (Alex Schimel)
% * YYYY-MM-DD: first version (Author). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [layers_out,surv_obj] = process_surveys(Filenames,varargin)

%% Managing input variables

% input parser
p = inputParser;

% add parameters
addRequired(p,'Filenames',@(x) ischar(x)|iscell(x)); % script file(s)
addParameter(p,'layers',layer_cl.empty(),@(obj) isa(obj,'layer_cl'));
addParameter(p,'origin','xml',@ischar); % script type "xml" or "mbs"
addParameter(p,'cvs_root','',@ischar);
addParameter(p,'data_root','',@ischar);
addParameter(p,'PathToMemmap','',@ischar);
addParameter(p,'tag','raw',@(x) ischar(x));
addParameter(p,'gui_main_handle',matlab.ui.Figure.empty(),@ishandle);

% parse
parse(p,Filenames,varargin{:});

% get results
layers_out      = p.Results.layers;
origin          = p.Results.origin;
cvs_root        = p.Results.cvs_root;
data_root       = p.Results.data_root;
PathToMemmap    = p.Results.PathToMemmap;
tag             = p.Results.tag;
gui_main_handle = p.Results.gui_main_handle;

%% processing

% check script filenames
if ~iscell(Filenames)
    Filenames = {Filenames};
end

% disable windows temporarily
enabled_obj = findobj(gui_main_handle,'Enable','on');
set(enabled_obj,'Enable','off');

% processing per script
for i = 1:length(Filenames)
    
    % step 1: cehck script and load files
    try
        
        surv_obj = survey_cl();
        
        % step 1.1 Check script
        switch origin
            % switch on script type
            
            case 'mbs'
                
                curr_mbs = Filenames{i};
                
                if~strcmp(curr_mbs,'')
                    [fileNames,outDir] = get_mbs_from_esp2(cvs_root,'MbsId',curr_mbs,'Rev',[]);
                end
                
                mbs = mbs_cl();
                mbs.readMbsScript(data_root,fileNames{1});
                rmdir(outDir,'s');
                
                surv_obj.SurvInput = mbs.mbs_to_survey_obj('type',tag);
                
            case 'xml'
                
                surv_obj.SurvInput = parse_survey_xml(Filenames{i});
                
                if isempty(surv_obj.SurvInput)
                    warning('Could not parse the XML script file %s.',Filenames{i});
                    continue;
                end
                
                [valid,~] = surv_obj.SurvInput.check_n_complete_input();
                
                if valid == 0
                    warning('XML script file %s does not appear valid. Please check the script.',Filenames{i});
                    continue;
                end
                
        end
        
        % ?
        if isdeployed
            if isempty(surv_obj.SurvInput.Algos)
                fields_req = {'power','sv','sp'};
            else
                fields_req = {};
            end
        else
            fields_req = {};
        end
        
        % step 1.2 Load files
        [layers_new,layers_old] = surv_obj.SurvInput.load_files_from_survey_input('PathToMemmap',PathToMemmap,'cvs_root',cvs_root,'origin',origin,...
            'layers',layers_out,'Fieldnames',fields_req,'gui_main_handle',gui_main_handle);
        
    catch err
        
        disp(err.message);
        warning('Script file %s could not be loaded.',Filenames{i});
        continue;
        
    end
    
    % step 2: reorganize layers    
    layers_out = [layers_old layers_new];
    layers_out = reorder_layers_time(layers_out);
    
    % path for saving results
    if isempty(gui_main_handle)
        [PathToFile,~,~] = fileparts(layers_new(end).Filename{1});
    else
        app_path = getappdata(gui_main_handle,'App_path');
        PathToFile = app_path.results;
        if exist(PathToFile,'dir') == 0
            mkdir(PathToFile);
        end
    end
    
    % step 3: run the integration script
    try
        surv_obj.generate_output_v2(layers_new,'PathToResults',PathToFile);
    catch err
        disp(err.message);
        warning('Script file %s could not be run.',Filenames{i});
    end
    
    % step 4: Save results in output files
    try
        
        
        save(fullfile(PathToFile,[surv_obj.SurvInput.Infos.Title '_survey_output.mat']),'surv_obj');
        outputFile = fullfile(PathToFile,[surv_obj.SurvInput.Infos.Title '_mbs_output.txt']);
        surv_obj.print_output(outputFile);
        fprintf(1,'Results save to %s \n',outputFile);
        outputFileXLS = fullfile(PathToFile,[surv_obj.SurvInput.Infos.Title '_xls_output.xlsx']);
        surv_obj.print_output_xls(outputFileXLS);
        fprintf(1,'Results save to %s \n',outputFileXLS);
        
    catch err
        disp(err.message);
        warning('Could not save results for survey described in file %s\n',Filenames{i});
        if ~isdeployed
            rethrow(err)
        end
        
    end
    
    
end

% re-enable windows
set(enabled_obj(isvalid(enabled_obj)),'Enable','on');

% hide status bar
hide_status_bar(gui_main_handle);


end