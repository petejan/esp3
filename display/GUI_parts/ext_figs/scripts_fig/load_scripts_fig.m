%% load_scripts_fig.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: Handle to main ESP3 window
% * |scriptsSummary|: TODO: write description and info on variable
% * |flag|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-02: header (Alex Schimel).
% * YYYY-MM-DD: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function load_scripts_fig(main_figure,scriptsSummary,flag)

hfigs=getappdata(main_figure,'ExternalFigures');
hfigs(~isvalid(hfigs))=[];
tag=sprintf('Scripting%s',flag);
idx_tag=find(strcmpi({hfigs(:).Tag},tag));

if ~isempty(idx_tag)
    figure(hfigs(idx_tag(1)))
    return;
end

% Column names and column format
columnname = {'Title','Species','Survey','Areas','Author','Script','Created'};
columnformat = {'char','char','char','char','char','char','char'};

script_fig = new_echo_figure(main_figure,'Units','Pixels','Position',[100 100 800 600],'Resize','off',...
    'Name',sprintf('Scripting (%s)',flag),...
    'Tag',tag,...
    'MenuBar','none');%No Matlab Menu)

uicontrol(script_fig,'style','text','BackgroundColor','White','units','normalized','position',[0.05 0.96 0.15 0.03],'String','Search: ');
script_table.search_box=uicontrol(script_fig,'style','edit','units','normalized','position',[0.2 0.96 0.3 0.03],'HorizontalAlignment','left','Callback',{@search_callback,script_fig});

uicontrol(script_fig,'style','text','BackgroundColor','White','units','normalized','position',[0.55 0.96 0.1 0.03],'String','Filter (or): ');
script_table.title_box=uicontrol(script_fig,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.65 0.96 0.1 0.03],'String','Titles','Value',1,'Callback',{@search_callback,script_fig});
script_table.species_box=uicontrol(script_fig,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.75 0.96 0.1 0.03],'String','Species','Value',1,'Callback',{@search_callback,script_fig});
script_table.voyage_box=uicontrol(script_fig,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.85 0.96 0.1 0.03],'String','Voyage','Value',1,'Callback',{@search_callback,script_fig});


% Create the uitable
script_table.table_main = uitable('Parent',script_fig,...
    'Data', scriptsSummary,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'ColumnEditable', [false false false false false false],...
    'Units','Normalized','Position',[0 0 1 0.95],...
    'RowName',[]);

pos_t = getpixelposition(script_table.table_main);

set(script_table.table_main,'ColumnWidth',{2*pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, 2*pos_t(3)/10, 2*pos_t(3)/10});
set(script_table.table_main,'CellSelectionCallback',{@store_selected_script_callback,script_fig})

rc_menu = uicontextmenu(ancestor(script_table.table_main,'figure'));
script_table.table_main.UIContextMenu =rc_menu;
switch flag
    case 'mbs'
        uimenu(rc_menu,'Label','Run on Crest Files','Callback',{@run_script_callback_v2,script_fig,main_figure,flag},'tag','crest');
        uimenu(rc_menu,'Label','Run on Raw Files','Callback',{@run_script_callback_v2,script_fig,main_figure,flag},'tag','raw');
        uimenu(rc_menu,'Label','Generate Equivalent XML Script','Callback',{@generate_xml_scripts_callback,script_fig,main_figure});
        uimenu(rc_menu,'Label','Populate Logbook from MBS Script','Callback',{@populate_logbook_from_script_callback,script_fig,main_figure});
        
    case 'xml'
        uimenu(rc_menu,'Label','Run','Callback',{@run_script_callback_v2,script_fig,main_figure,flag});
        uimenu(rc_menu,'Label','Check Script','Callback',{@check_xml_scripts_callback,script_fig,main_figure});
        uimenu(rc_menu,'Label','Reload Figure','Callback',{@reload_callback,script_fig,main_figure});
end

uimenu(rc_menu,'Label','Edit','Callback',{@edit_script_callback,script_fig,main_figure,flag});
selected_scripts={''};

setappdata(script_fig,'SelectedScripts',selected_scripts);
setappdata(script_fig,'script_table',script_table);
setappdata(script_fig,'DataOri',scriptsSummary);

end

function generate_xml_scripts_callback(~,~,hObject,main_figure)
selected_scripts=getappdata(hObject,'SelectedScripts');
app_path=getappdata(main_figure,'App_path');

curr_mbs=selected_scripts{1};

if~strcmp(curr_mbs,'')
    [fileNames,outDir]=get_mbs_from_esp2(app_path.cvs_root,'MbsId',curr_mbs,'Rev',[]);
end

mbs=mbs_cl();
mbs.readMbsScript(app_path.data_root,fileNames{1});
rmdir(outDir,'s');
surv_obj=survey_cl();
surv_obj.SurvInput=mbs.mbs_to_survey_obj('type','raw');


[filename, pathname] = uiputfile('*.xml',...
    'Save survey XML file',...
    fullfile(app_path.scripts,[surv_obj.SurvInput.Infos.Voyage '.xml']));

if isequal(filename,0) || isequal(pathname,0)
    return;
end
surv_obj.SurvInput.survey_input_to_survey_xml('xml_filename',fullfile(pathname,filename));

end

function populate_logbook_from_script_callback(~,~,hObject,main_figure)
selected_scripts=getappdata(hObject,'SelectedScripts');
app_path=getappdata(main_figure,'App_path');

curr_mbs=selected_scripts{1};

if~strcmp(curr_mbs,'')
    [fileNames,outDir]=get_mbs_from_esp2(app_path.cvs_root,'MbsId',curr_mbs,'Rev',[]);
end

mbs=mbs_cl();
mbs.readMbsScript(app_path.data_root,fileNames{1});
rmdir(outDir,'s');
surv_obj=survey_cl();
surv_obj.SurvInput=mbs.mbs_to_survey_obj('type','raw');
infos=surv_obj.SurvInput.Infos;
for ifile=1:length(mbs.Input.snapshot)
    if ~strcmpi(mbs.Input.rawFileName{ifile},'')
        fprintf('Adding Survey Data for File %s\n',mbs.Input.rawFileName{ifile});
        surv=survey_data_cl('Voyage',infos.Voyage,'SurveyName',infos.SurveyName,'Snapshot',mbs.Input.snapshot(ifile),'Stratum',mbs.Input.stratum{ifile},'Transect',mbs.Input.transect(ifile));
        layer_cl.empty.update_echo_logbook_dbfile('Filename',fullfile(mbs.Input.rawDir{ifile},mbs.Input.rawFileName{ifile}),'SurveyData',surv,'Voyage',infos.Voyage,'SurveyName',infos.SurveyName);
    end
end

end

function reload_callback(~,~,hObject,main_figure)
delete(hObject);
load_xml_scripts_callback([],[],main_figure)
end

function run_script_callback_v2(src,~,hObject,main_figure,flag)

selected_scripts=getappdata(hObject,'SelectedScripts');
app_path=getappdata(main_figure,'App_path');
layers=getappdata(main_figure,'Layers');


switch flag
    case 'mbs'
        [layers,~]=process_surveys(selected_scripts,'PathToMemmap',app_path.data_temp,'layers',layers,'origin','mbs','cvs_root',app_path.cvs_root,'data_root',app_path.data_root,'tag',src.Tag,'gui_main_handle',main_figure);
    case 'xml'
        selected_scripts_full=cellfun(@(x) fullfile(app_path.scripts,x),selected_scripts,'UniformOutput',0);
        [layers,~]=process_surveys(selected_scripts_full,'PathToMemmap',app_path.data_temp,'layers',layers,'origin','xml','gui_main_handle',main_figure);
end
if ~isempty(layers)
    [~,found]=find_layer_idx(layers,0);
else
    found=0;
end
if  found==1
    layers=layers.delete_layers(0);
end

if ~isempty(layers)
    layer=layers(end);
    setappdata(main_figure,'Layer',layer);
    setappdata(main_figure,'Layers',layers);
    loadEcho(main_figure);
end

end

function check_xml_scripts_callback(~,~,hObject,main_figure)
app_path=getappdata(main_figure,'App_path');
selected_scripts=getappdata(hObject,'SelectedScripts');
surv_obj=survey_cl();
surv_obj.SurvInput=parse_survey_xml(fullfile(app_path.scripts,selected_scripts{end}));

if isempty(surv_obj.SurvInput)
    warning('Could not parse the File describing the survey...');
end

[valid,~]=surv_obj.SurvInput.check_n_complete_input();

if valid==0
    warning('It looks like there is a problem with XML survey file %s\n',selected_scripts{end});
else
    disp('Script appears to be valid...')
end
end

function edit_script_callback(~,~,hObject,main_figure,flag)
selected_scripts=getappdata(hObject,'SelectedScripts');
app_path=getappdata(main_figure,'App_path');
switch flag
    case 'mbs'
        if~strcmp(selected_scripts,'')
            [fileNames,outDir]=get_mbs_from_esp2(app_path.cvs_root,'MbsId',selected_scripts{end},'Rev',[]);
            [stat,~]=system(['start notepad++ ' fileNames{1}]);
            if stat~=0
                disp('You should install Notepad++...');
                system(['start ' fileNames{1}]);
            end
            pause(1);
            rmdir(outDir,'s');
        end
        
    case 'xml'
        [stat,~]=system(['start notepad++ ' fullfile(app_path.scripts,selected_scripts{end})]);
        if stat~=0
            disp('You should install Notepad++...');
            system(['start ' fullfile(app_path.scripts,selected_scripts{end})]);
        end
end
end

function store_selected_script_callback(src,event,hObject)

if size(event.Indices,1)>0
    selected_scripts=src.Data(event.Indices(:,1),6);
else
    selected_scripts={''};
end
setappdata(hObject,'SelectedScripts',selected_scripts);
end

function search_callback(~,~,script_fig)
table=getappdata(script_fig,'script_table');
data_ori=getappdata(script_fig,'DataOri');
text_search=regexprep(get(table.search_box,'string'),'[^\w'']','');
title_search=get(table.title_box,'value');
voyage_search=get(table.voyage_box,'value');
species_search=get(table.species_box,'value');

if isempty(text_search)||(voyage_search==0&&title_search==0&&species_search==0)
    data=data_ori;
else
    
    if voyage_search>0
        voyages=regexprep(data_ori(:,3),'[^\w'']','');
        out_voyage=regexpi(voyages,text_search);
        idx_voyage=cellfun(@(x) ~isempty(x),out_voyage);
    else
        idx_voyage=zeros(size(data_ori,1),1);
    end
    
    if species_search>0
        species=regexprep(data_ori(:,2),'[^\w'']','');
        out_species=regexpi(species,text_search);
        idx_species=cellfun(@(x) ~isempty(x),out_species);
    else
        idx_species=zeros(size(data_ori,1),1);
    end
    
    if title_search>0
        titles=regexprep(data_ori(:,1),'[^\w'']','');
        out_title=regexpi(titles,text_search);
        idx_title=cellfun(@(x) ~isempty(x),out_title);
    else
        idx_title=zeros(size(data_ori,1),1);
    end
    
    
    data=data_ori(idx_voyage|idx_title|idx_species,:);
end

set(table.table_main,'Data',data);
setappdata(script_fig,'script_table',table);
end

