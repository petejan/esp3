function edit_survey_info_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

surveydata=layer.get_survey_data();

prompt={'Survey Name',...
    'Voyage',...
    'Snapshot',...
    'Stratum',...
    'Transect'};
name='Survey Data';
numlines=1;

if ~isempty(surveydata)
defaultanswer={surveydata.SurveyName,surveydata.Voyage,num2str(surveydata.Snapshot,'%d'),num2str(surveydata.Stratum,'%d'),num2str(surveydata.Transect,'%d')};
else
defaultanswer={'','','','',''};
end

answer=inputdlg(prompt,name,numlines,defaultanswer);

if isempty(answer)
    return;
end

SurveyName=answer{1};
Voyage=answer{2};

if ~isnan(str2double(answer{3}))
    Snapshot=floor(str2double(answer{3}));
else
    warning('Invalid Snapshot number.');return;
end

Stratum=answer{4};

if ~isnan(str2double(answer{5}))
    Transect=floor(str2double(answer{5}));
else
    warning('Invalid Transect number');return;
end

survd=survey_data_cl('Voyage',Voyage,'SurveyName',SurveyName,'Snapshot',Snapshot,'Stratum',Stratum,'Transect',Transect);

layer.set_survey_data(survd);

layer.update_echo_logbook_file();

setappdata(main_figure,'Layer',layer);
load_cursor_tool(main_figure);

end