function load_logbook_from_csv_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
   path_init=pwd;
   surveydata=survey_data_cl();
else
   [path_init,~]=layer.get_path_files();
   surveydata=layer.get_survey_data();
end

[csv_file,path_f]= uigetfile(fullfile(path_init,'*.csv;*.txt'), 'Choose csv_file','MultiSelect','off');

if path_f==0
    return;
end


[Voyage,SurveyName,~,~,~,can]=fill_survey_data_dlbox(surveydata,'Voyage_only',1,'Title','Set Voyage Info');

if can>0
    return;
end

csv_logbook_to_xml(path_f,csv_file,Voyage,SurveyName);
xml_logbook_to_db(fullfile(path_f,'echo_logbook.db'));
import_survey_data_callback([],[],main_figure);
load_survey_data_fig_from_db(main_figure);

end