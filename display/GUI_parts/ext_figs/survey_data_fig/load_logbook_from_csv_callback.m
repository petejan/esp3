function load_logbook_from_csv_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    path_init = uigetdir(app_path.data,'Choose Data Folder');
    if path_init==0
        return;
    end
else
    [path_lay,~]=get_path_files(layer);
    path_init=path_lay{1};
end

[csv_file,path_f]= uigetfile(fullfile(path_init,'*.csv;*.txt'), 'Choose csv_file','MultiSelect','off');

if path_f==0
    return;
end


[Voyage,SurveyName,~,~,~,can]=fill_survey_data_dlbox(surveydata,'Voyage_only',1,'Title','Set Voyage Info');

if can>0
    return;
end

csv_logbook_to_db(path_f,csv_file,Voyage,SurveyName);

import_survey_data_callback([],[],main_figure);
load_survey_data_fig_from_db(main_figure,0);

end