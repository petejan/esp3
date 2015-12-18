function edit_survey_info_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
surveydata=layer.SurveyData;

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
survd=survey_data_cl();

survd.SurveyName=answer{1};
survd.Voyage=answer{2};

if ~isnan(str2double(answer{3}))
    survd.Snapshot=floor(str2double(answer{3}));
else
    warning('Invalid Snapshot number.');
end

survd.Stratum=answer{4};

if ~isnan(str2double(answer{5}))
    survd.Transect=floor(str2double(answer{5}));
else
    warning('Invalid Transect number');
end

layer.SurveyData=survd;
setappdata(main_figure,'Layer',layer);
load_cursor_tool(main_figure);

end