function load_survey_data_fig(hObject_main)
hfigs=getappdata(hObject_main,'ExternalFigures');
layer=getappdata(hObject_main,'Layer');
surv_data_struct=layer.get_logbook_struct();

survDataSummary=cell(length(surv_data_struct.Filename),6);

survDataSummary(:,1)=surv_data_struct.Filename;
survDataSummary(:,2)=num2cell(surv_data_struct.Snapshot);
survDataSummary(:,3)=surv_data_struct.Stratum;
survDataSummary(:,4)=num2cell(surv_data_struct.Transect);
survDataSummary(:,5)=num2cell(surv_data_struct.StartTime);
survDataSummary(:,6)=num2cell(surv_data_struct.EndTime);


% Column names and column format
columnname = {'Filename','Snapshot','Stratum','Transect','Start Time','End Time'};
columnformat = {'char','numeric','char','numeric','char','char'};

surv_data_fig = figure('Position',[100 100 800 600],'Resize','off',...
    'Name','SurveyData','NumberTitle','off',...
    'MenuBar','none');%No Matlab Menu)
hfigs_new=[hfigs surv_data_fig];
setappdata(hObject_main,'ExternalFigures',hfigs_new);
% 
% uicontrol(surv_data_fig,'style','text','units','normalized','position',[0.05 0.96 0.15 0.03],'String','Search: ');
% surv_data_table.search_box=uicontrol(surv_data_fig,'style','edit','units','normalized','position',[0.2 0.96 0.3 0.03],'HorizontalAlignment','left','Callback',{@search_callback,surv_data_fig});
% 
% uicontrol(surv_data_fig,'style','text','units','normalized','position',[0.55 0.96 0.1 0.03],'String','Filter (or): ');
% surv_data_table.title_box=uicontrol(surv_data_fig,'style','checkbox','units','normalized','position',[0.65 0.96 0.1 0.03],'String','Titles','Value',1,'Callback',{@search_callback,surv_data_fig});
% surv_data_table.species_box=uicontrol(surv_data_fig,'style','checkbox','units','normalized','position',[0.75 0.96 0.1 0.03],'String','Species','Value',1,'Callback',{@search_callback,surv_data_fig});
% surv_data_table.voyage_box=uicontrol(surv_data_fig,'style','checkbox','units','normalized','position',[0.85 0.96 0.1 0.03],'String','Voyage','Value',1,'Callback',{@search_callback,surv_data_fig});
% 

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
set(surv_data_table.table_main,'ColumnWidth',{2*pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, 2*pos_t(3)/10, 2*pos_t(3)/10});
%set(surv_data_table.table_main,'CellSelectionCallback',{@store_selected_transect_callback,surv_data_fig})

% rc_menu = uicontextmenu;
% surv_data_table.table_main.UIContextMenu =rc_menu;
% uimenu(rc_menu,'Label','Run on Crest Files','Callback',{@run_mbs_callback,surv_data_fig,hObject_main},'tag','crest');
% uimenu(rc_menu,'Label','Run on Raw Files','Callback',{@run_mbs_callback,surv_data_fig,hObject_main},'tag','raw');
% uimenu(rc_menu,'Label','Run with school detection','Callback',{@run_mbs_callback,surv_data_fig,hObject_main},'tag','sch');
% uimenu(rc_menu,'Label','Edit','Callback',{@edit_mbs_callback,surv_data_fig,hObject_main});
selected_trans={''};

setappdata(surv_data_fig,'SelectedTrans',selected_trans);
setappdata(surv_data_fig,'surv_data_table',surv_data_table);

end
% 
% function edit_mbs_callback(~,~,hObject,hObject_main)
% app_path=getappdata(hObject_main,'App_path');
% selected_trans=getappdata(hObject,'SelectedTrans');
% if~strcmp(selected_trans,'')
%     [fileNames,outDir]=get_mbs_from_esp2(app_path.cvs_root,'MbsId',selected_trans{end},'Rev',[]);
%     edit(fileNames{1});
%     rmdir(outDir,'s');
% end
% end
