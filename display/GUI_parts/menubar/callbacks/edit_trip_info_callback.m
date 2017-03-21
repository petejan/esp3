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
layer.update_echo_logbook_dbfile('SurveyName',SurveyName,'Voyage',Voyage);
update_mini_ax(main_figure,0);
setappdata(main_figure,'Layer',layer);
import_survey_data_callback([],[],main_figure);
update_layer_tab(main_figure);
load_info_panel(main_figure);
update_mini_ax(main_figure,0);

load_survey_data_fig_from_db(main_figure,1);

end