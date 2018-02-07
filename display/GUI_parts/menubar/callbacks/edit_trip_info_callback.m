function edit_trip_info_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

surveydata=layer.get_survey_data();

[Voyage,SurveyName,~,~,~,can]=fill_survey_data_dlbox(surveydata,'Voyage_only',1,'Title','Edit Voyage Info');
if can>0
    return;
end

[path_lay,~]=get_path_files(layer);
path_f=path_lay{1};
db_file=fullfile(path_f,'echo_logbook.db');

if ~(exist(db_file,'file')==2)
    initialize_echo_logbook_dbfile(path_f,0)
end

%surv_data_struct=import_survey_data_db(db_file);

hfigs=getappdata(main_figure,'ExternalFigures');
hfigs(~isvalid(hfigs))=[];

if ~isempty(hfigs) 
    tag=sprintf('logbook_%s',path_f);
    idx_tag=find(strcmpi({hfigs(:).Tag},tag));
    if~isempty(idx_tag)
        set(hfigs(idx_tag(1)),'Name',sprintf('%s',Voyage));
    end
end

layer.update_echo_logbook_dbfile('SurveyName',SurveyName,'Voyage',Voyage);
update_mini_ax(main_figure,0);
setappdata(main_figure,'Layer',layer);
import_survey_data_callback([],[],main_figure);
update_layer_tab(main_figure);
load_info_panel(main_figure);
update_mini_ax(main_figure,0);

load_survey_data_fig_from_db(main_figure,1);

end