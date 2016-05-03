function edit_trip_info_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
layers=getappdata(main_figure,'Layers');
if isempty(layer)
    return;
end

surveydata=layer.get_survey_data();

[Voyage,SurveyName,~,~,~,can]=fill_survey_data_dlbox(surveydata,'Voyage_only',1,'Title','Edit Voyage Info');
if can>0
    return;
end
layer.update_echo_logbook_file('SurveyName',SurveyName,'Voyage',Voyage);

for i=1:length(layers)
    if ~isempty(layers(i).SurveyData)
        survd_new=cell(1,length(layers(i).SurveyData));
        for ui=1:length(layers(i).SurveyData)           
            survd=layers(i).get_survey_data('Idx',ui);
            if ~isempty(survd)
                survd_new{ui}=survey_data_cl('Voyage',Voyage,'SurveyName',SurveyName,...
                    'Snapshot',survd.Snapshot,'Stratum',survd.Stratum,'Transect',survd.Transect,'StartTime',survd.StartTime,'EndTime',survd.EndTime);
            else
                survd_new{ui}=survey_data_cl('Voyage',Voyage,'SurveyName',SurveyName);
            end
        end
    else
        survd_new=survey_data_cl('Voyage',Voyage,'SurveyName',SurveyName);
    end
    layers(i).set_survey_data(survd_new);
end

setappdata(main_figure,'Layer',layer);
load_cursor_tool(main_figure);
update_display(main_figure,0);
end