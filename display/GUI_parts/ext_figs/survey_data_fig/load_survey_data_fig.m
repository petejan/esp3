function load_survey_data_fig(main_figure)
hfigs=getappdata(main_figure,'ExternalFigures');
layer=getappdata(main_figure,'Layer');

if isempty(layer)
   return; 
end

surv_data_struct=layer.get_logbook_struct();

if isempty(surv_data_struct.Voyage)
   return; 
end

[path_f,~]=layer.get_path_files();

survDataSummary=cell(length(surv_data_struct.Filename),8);

survDataSummary(:,1)=cell(size(surv_data_struct.Filename));

survDataSummary(:,2)=surv_data_struct.Filename;
survDataSummary(:,3)=num2cell(surv_data_struct.Snapshot);
survDataSummary(:,4)=surv_data_struct.Stratum;
survDataSummary(:,5)=num2cell(surv_data_struct.Transect);
for i=1:length(surv_data_struct.SurvDataObj)
    survDataSummary{i,1}=false;
    survDataSummary{i,6}=datestr(surv_data_struct.SurvDataObj{i}.StartTime,'dd-mmm-yyyy HH:MM:SS');
    survDataSummary{i,7}=datestr(surv_data_struct.SurvDataObj{i}.EndTime,'dd-mmm-yyyy HH:MM:SS');
    survDataSummary{i,8}=i;
end

% Column names and column format
columnname = {'' 'Filename','Snapshot','Stratum','Transect','Start Time','End Time' 'id'};
columnformat = {'logical' 'char','numeric','char','numeric','char','char'};

surv_data_fig = figure('Position',[100 100 800 600],'Resize','off',...
    'Name','SurveyData','NumberTitle','off','tag','logbook',...
    'MenuBar','none');%No Matlab Menu)
hfigs_new=[hfigs surv_data_fig];
setappdata(main_figure,'ExternalFigures',hfigs_new);
% 
uicontrol(surv_data_fig,'style','text','units','normalized','position',[0.05 0.96 0.3 0.03],'String',sprintf('Voyage %s, Survey: %s',surv_data_struct.Voyage{1},surv_data_struct.SurveyName{1}));
uicontrol(surv_data_fig,'style','text','units','normalized','position',[0.35 0.96 0.1 0.03],'String','Search :');


surv_data_table.search_box=uicontrol(surv_data_fig,'style','edit','units','normalized','position',[0.45 0.96 0.2 0.03],'HorizontalAlignment','left','Callback',{@search_callback,surv_data_fig});
%uicontrol(surv_data_fig,'style','text','units','normalized','position',[0.65 0.96 0.1 0.03],'String','Filter (or): ');
%surv_data_table.strat_box=uicontrol(surv_data_fig,'style','checkbox','units','normalized','position',[0.7 0.96 0.1 0.03],'String','Stratum','Value',1,'Callback',{@search_callback,surv_data_fig});
% surv_data_table.species_box=uicontrol(surv_data_fig,'style','checkbox','units','normalized','position',[0.75 0.96 0.1 0.03],'String','Species','Value',1,'Callback',{@search_callback,surv_data_fig});
% surv_data_table.voyage_box=uicontrol(surv_data_fig,'style','checkbox','units','normalized','position',[0.85 0.96 0.1 0.03],'String','Voyage','Value',1,'Callback',{@search_callback,surv_data_fig});

 
surv_data_table.save_button=uicontrol(surv_data_fig,'style','pushbutton','units','normalized','position',[0.85 0.96 0.1 0.03],'String','Save','Value',1,'Callback',{@save_logbook_callback,surv_data_fig,main_figure});


% Create the uitable
surv_data_table.table_main = uitable('Parent',surv_data_fig,...
    'Data', survDataSummary,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'ColumnEditable', [true false true true true false],...
    'Units','Normalized','Position',[0 0 1 0.95],...
    'RowName',[]);

set(surv_data_table.table_main,'Units','pixels');
pos_t=get(surv_data_table.table_main,'Position');
set(surv_data_table.table_main,'ColumnWidth',{pos_t(3)/12,3*pos_t(3)/12, pos_t(3)/12, pos_t(3)/12, pos_t(3)/12, 2*pos_t(3)/12, 2*pos_t(3)/12, pos_t(3)/12});
set(surv_data_table.table_main,'CellEditCallback',{@update_surv_data_struct,surv_data_fig});
set(surv_data_table.table_main,'CellSelectionCallback',{@update_surv_data_struct,surv_data_fig});


rc_menu = uicontextmenu;
surv_data_table.table_main.UIContextMenu =rc_menu;
uimenu(rc_menu,'Label','Open selected file(s)','Callback',{@open_files_callback,surv_data_fig,main_figure});
uimenu(rc_menu,'Label','XML Survey Script from selected file(s)','Callback',{@generate_xml_callback,surv_data_fig});
uimenu(rc_menu,'Label','Select all','Callback',{@selection_callback,surv_data_fig},'Tag','se');
uimenu(rc_menu,'Label','Deselect all','Callback',{@selection_callback,surv_data_fig},'Tag','de');
uimenu(rc_menu,'Label','Invert Selection','Callback',{@selection_callback,surv_data_fig},'Tag','inv');
setappdata(surv_data_fig,'surv_data_struct',surv_data_struct);
setappdata(surv_data_fig,'path_data',path_f{1});
setappdata(surv_data_fig,'surv_data_table',surv_data_table);
setappdata(surv_data_fig,'data_ori',survDataSummary);
end


function update_surv_data_struct(src,evt,surv_data_fig)
if isempty(evt.Indices)
   return; 
end
surv_data_struct=getappdata(surv_data_fig,'surv_data_struct');
data_ori=getappdata(surv_data_fig,'data_ori');
if isnan(src.Data{evt.Indices(1),evt.Indices(2)})
    src.Data{evt.Indices(1),evt.Indices(2)}=0;
end

idx_struct=src.Data{evt.Indices(1),8};

switch evt.Indices(2)
    case 1
        data_ori{idx_struct,1}=src.Data{evt.Indices(1),evt.Indices(2)};
    case 2
        data_ori{idx_struct,1}=~data_ori{idx_struct,1};
        src.Data{evt.Indices(1),1}=data_ori{idx_struct,1};
    case 3
        surv_data_struct.Snapshot(idx_struct)=src.Data{evt.Indices(1),evt.Indices(2)};
        surv_data_struct.SurvDataObj{idx_struct}.Snapshot=src.Data{evt.Indices(1),evt.Indices(2)};
    case 4
        surv_data_struct.Stratum{idx_struct}=src.Data{evt.Indices(1),evt.Indices(2)};
        surv_data_struct.SurvDataObj{idx_struct}.Stratum=src.Data{evt.Indices(1),evt.Indices(2)};
    case 5
        surv_data_struct.Transect(idx_struct)=src.Data{evt.Indices(1),evt.Indices(2)};
        surv_data_struct.SurvDataObj{idx_struct}.Transect=src.Data{evt.Indices(1),evt.Indices(2)};
end

data_ori{idx_struct,evt.Indices(2)}=src.Data{evt.Indices(1),evt.Indices(2)};
setappdata(surv_data_fig,'surv_data_struct',surv_data_struct);
setappdata(surv_data_fig,'data_ori',data_ori);
end

function save_logbook_callback(~,~,surv_data_fig,main_figure)
path_f=getappdata(surv_data_fig,'path_data');
surv_data_struct=getappdata(surv_data_fig,'surv_data_struct');
survey_data_struct_to_xml(path_f,surv_data_struct);
import_survey_data_callback([],[],main_figure);
%close(surv_data_fig);
end


function selection_callback(src,~,surv_data_fig)
    surv_data_table=getappdata(surv_data_fig,'surv_data_table');
    data_ori=getappdata(surv_data_fig,'data_ori');
    data=get(surv_data_table.table_main,'Data');
    for i=1:size(data,1)
        switch src.Tag
            case 'se'
                data{i,1}=1;
            case 'de'
                 data{i,1}=0;
            case 'inv'
                 data{i,1}=~data{i,1};
        end
        data_ori{data{i,8},1}=data{i,1};
    end
    set(surv_data_table.table_main,'Data',data);
    setappdata(surv_data_fig,'data_ori',data_ori);
end


function open_files_callback(~,~,surv_data_fig,main_figure)
    surv_data_table=getappdata(surv_data_fig,'surv_data_table');
    data_ori=get(surv_data_table.table_main,'Data');
  selected_files=unique(data_ori([data_ori{:,1}],2));
  path_f=getappdata(surv_data_fig,'path_data');
    files=fullfile(path_f,selected_files);
    open_file([],[],files,main_figure);
end

function generate_xml_callback(~,~,surv_data_fig)
surv_data_table=getappdata(surv_data_fig,'surv_data_table');
surv_data_struct=getappdata(surv_data_fig,'surv_data_struct');
data_ori=get(surv_data_table.table_main,'Data');
path_f=getappdata(surv_data_fig,'path_data');
idx_struct=unique([data_ori{[data_ori{:,1}],8}]);

survey_input_obj=survey_input_cl();

survey_input_obj.Infos.SurveyName=surv_data_struct.SurveyName{idx_struct(1)};
survey_input_obj.Infos.Voyage=surv_data_struct.Voyage{idx_struct(1)};

snapshots=unique(surv_data_struct.Snapshot(idx_struct));
survey_input_obj.Snapshots=cell(1,length(snapshots));
for isnap=1:length(snapshots)
    
    survey_input_obj.Snapshots{isnap}.Folder=path_f;
    survey_input_obj.Snapshots{isnap}.Number=snapshots(isnap);
    idx_snap=idx_struct(surv_data_struct.Snapshot(idx_struct)==snapshots(isnap));
    stratum=unique(surv_data_struct.Stratum(idx_snap));
    survey_input_obj.Snapshots{isnap}.Stratum=cell(1,length(stratum));
    
    for istrat=1:length(stratum)
        idx_strat=idx_snap(strcmp(surv_data_struct.Stratum(idx_snap),stratum{istrat}));
        survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Name=stratum{istrat};
        transects=unique(surv_data_struct.Transect(idx_strat));
        survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects=cell(1,length(transects));
        for itrans=1:length(transects)
            survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.number=transects(itrans);
            survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.Bottom=struct('ver',1);
            survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.Regions{1}=struct('ver',1,'IDs',[]);
            survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.Cal=[];
        end
    end
    
end
survey_input_obj.check_n_complete_input();

[filename, pathname] = uiputfile('*.xml',...
                       'Save survey XML file',...
                       fullfile(path_f,[survey_input_obj.Infos.Voyage '.xml']));
                   
if isequal(filename,0) || isequal(pathname,0)
   return;
end

survey_input_obj.survey_input_to_survey_xml('xml_filename',fullfile(pathname,filename));

end

function search_callback(~,~,surv_fig)
surv_data_table=getappdata(surv_fig,'surv_data_table');
data_ori=getappdata(surv_fig,'data_ori');
text_search=regexprep(get(surv_data_table.search_box,'string'),'[^\w'']','');


if isempty(text_search)
    data=data_ori;
else
    

    strat=regexprep(data_ori(:,4),'[^\w'']','');
    out_strat=regexpi(strat,text_search);
    idx_strat=cellfun(@(x) ~isempty(x),out_strat);
    
    files=regexprep(data_ori(:,2),'[^\w'']','');
    out_files=regexpi(files,text_search);
    idx_files=cellfun(@(x) ~isempty(x),out_files);

    data=data_ori(idx_strat|idx_files,:);
end

set(surv_data_table.table_main,'Data',data);

end

