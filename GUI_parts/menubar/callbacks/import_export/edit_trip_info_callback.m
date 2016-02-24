function edit_trip_info_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
layers=getappdata(main_figure,'Layers');
if isempty(layer)
    return;
end

surveydata=layer.get_survey_data();

prompt={'Survey Name',...
    'Voyage'};
name='Trip Info';
numlines=1;

if ~isempty(surveydata)
    defaultanswer={surveydata.SurveyName,surveydata.Voyage};
else
    defaultanswer={' ',' '};
end

answer=inputdlg(prompt,name,numlines,defaultanswer);

if isempty(answer)
    return;
end

SurveyName=answer{1};
Voyage=answer{2};

layer.update_echo_logbook_file('SurveyName',SurveyName,'Voyage',Voyage);

for i=1:length(layers)
    if ~isempty(layers(i).SurveyData)
        for ui=1:length(layers(i).SurveyData)
            survd_new=cell(1,length(layers(i).SurveyData));
            survd=layers(i).get_survey_data('Idx',ui);
            if ~isempty(survd)
                survd_new{ui}=survey_data_cl('Voyage',Voyage,'SurveyName',SurveyName,...
                    'Snapshot',survd.Snapshot,'Stratum',survd.Stratum,'Transect',survd.Transect);
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