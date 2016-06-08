function load_survey_data_fig(main_figure)
hfigs=getappdata(main_figure,'ExternalFigures');
layer=getappdata(main_figure,'Layer');
surv_data_struct=layer.get_logbook_struct();

survDataSummary=cell(length(surv_data_struct.Filename),6);

survDataSummary(:,1)=surv_data_struct.Filename;
survDataSummary(:,2)=num2cell(surv_data_struct.Snapshot);
survDataSummary(:,3)=surv_data_struct.Stratum;
survDataSummary(:,4)=num2cell(surv_data_struct.Transect);
for i=1:length(surv_data_struct.SurvDataObj)
    survDataSummary{i,5}=datestr(surv_data_struct.SurvDataObj{i}.StartTime,'dd-mmm-yyyy HH:MM:SS');
    survDataSummary{i,6}=datestr(surv_data_struct.SurvDataObj{i}.EndTime,'dd-mmm-yyyy HH:MM:SS');
end

% Column names and column format
columnname = {'Filename','Snapshot','Stratum','Transect','Start Time','End Time'};
columnformat = {'char','numeric','char','numeric','char','char'};

surv_data_fig = figure('Position',[100 100 800 600],'Resize','off',...
    'Name','SurveyData','NumberTitle','off',...
    'MenuBar','none');%No Matlab Menu)
hfigs_new=[hfigs surv_data_fig];
setappdata(main_figure,'ExternalFigures',hfigs_new);
% 
% uicontrol(surv_data_fig,'style','text','units','normalized','position',[0.05 0.96 0.15 0.03],'String','Search: ');
% surv_data_table.search_box=uicontrol(surv_data_fig,'style','edit','units','normalized','position',[0.2 0.96 0.3 0.03],'HorizontalAlignment','left','Callback',{@search_callback,surv_data_fig});
% 
% uicontrol(surv_data_fig,'style','text','units','normalized','position',[0.55 0.96 0.1 0.03],'String','Filter (or): ');
% surv_data_table.title_box=uicontrol(surv_data_fig,'style','checkbox','units','normalized','position',[0.65 0.96 0.1 0.03],'String','Titles','Value',1,'Callback',{@search_callback,surv_data_fig});
% surv_data_table.species_box=uicontrol(surv_data_fig,'style','checkbox','units','normalized','position',[0.75 0.96 0.1 0.03],'String','Species','Value',1,'Callback',{@search_callback,surv_data_fig});
% surv_data_table.voyage_box=uicontrol(surv_data_fig,'style','checkbox','units','normalized','position',[0.85 0.96 0.1 0.03],'String','Voyage','Value',1,'Callback',{@search_callback,surv_data_fig});
% 
 surv_data_table.save_button=uicontrol(surv_data_fig,'style','pushbutton','units','normalized','position',[0.85 0.96 0.1 0.03],'String','Save','Value',1,'Callback',{@save_logbook_callback,surv_data_fig,main_figure});


% Create the uitable
surv_data_table.table_main = uitable('Parent',surv_data_fig,...
    'Data', survDataSummary,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'ColumnEditable', [false true true true false],...
    'Units','Normalized','Position',[0 0 1 0.95],...
    'RowName',[]);

set(surv_data_table.table_main,'Units','pixels');
pos_t=get(surv_data_table.table_main,'Position');
set(surv_data_table.table_main,'ColumnWidth',{pos_t(3)/4, pos_t(3)/12, pos_t(3)/12, pos_t(3)/12, pos_t(3)/4, pos_t(3)/4});
set(surv_data_table.table_main,'CellEditCallback',{@update_surv_data_struct,surv_data_fig})



setappdata(surv_data_fig,'surv_data_struct',surv_data_struct);
setappdata(surv_data_fig,'surv_data_table',surv_data_table);

end

function update_surv_data_struct(src,evt,surv_data_fig)
surv_data_struct=getappdata(surv_data_fig,'surv_data_struct');

if isnan(src.Data{evt.Indices(1),evt.Indices(2)})
    src.Data{evt.Indices(1),evt.Indices(2)}=0;
end

switch evt.Indices(2)
    case 2
        surv_data_struct.Snapshot(evt.Indices(1))=src.Data{evt.Indices(1),evt.Indices(2)};
        surv_data_struct.SurvDataObj{evt.Indices(1)}.Snapshot=src.Data{evt.Indices(1),evt.Indices(2)};
    case 3
        surv_data_struct.Stratum{evt.Indices(1)}=src.Data{evt.Indices(1),evt.Indices(2)};
        surv_data_struct.SurvDataObj{evt.Indices(1)}.Stratum=src.Data{evt.Indices(1),evt.Indices(2)};
    case 4
        surv_data_struct.Transect(evt.Indices(1))=src.Data{evt.Indices(1),evt.Indices(2)};
        surv_data_struct.SurvDataObj{evt.Indices(1)}.Transect=src.Data{evt.Indices(1),evt.Indices(2)};
end

setappdata(surv_data_fig,'surv_data_struct',surv_data_struct);
end

function save_logbook_callback(~,~,surv_data_fig,main_figure)
layer_obj=getappdata(main_figure,'Layer');
surv_data_struct=getappdata(surv_data_fig,'surv_data_struct');
[path_f,~]=layer_obj.get_path_files();
survey_data_struct_to_xml(path_f{1},surv_data_struct);
import_survey_data_callback([],[],main_figure);
end
