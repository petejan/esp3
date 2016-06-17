
function [Voyage,SurveyName,Snapshot,Stratum,Transect,cancel]=fill_survey_data_dlbox(surveydata,varargin)

p = inputParser;

addRequired(p,'surv_input_obj',@(obj) isa(obj,'survey_data_cl')||isempty(obj));
addParameter(p,'Voyage_only',0,@isnumeric);
addParameter(p,'Title','Survey Data',@ischar);

parse(p,surveydata,varargin{:});

cancel=0;
numlines=1;
name=p.Results.Title;
if p.Results.Voyage_only>0
    
    prompt={'Survey Name',...
        'Voyage'};
    
    if ~isempty(surveydata)
        defaultanswer={surveydata.SurveyName,surveydata.Voyage};
    else
        defaultanswer={'',''};
    end
    
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    
    if isempty(answer)
        answer=defaultanswer;
        cancel=1;
    end
    
    SurveyName=answer{1};
    Voyage=answer{2};
else
    prompt={'Snapshot',...
        'Stratum',...
        'Transect'};
    
    if ~isempty(surveydata)
        defaultanswer={num2str(surveydata.Snapshot,'%d'),num2str(surveydata.Stratum,'%d'),num2str(surveydata.Transect,'%d')};
    else
        defaultanswer={'0','','0'};
    end
    
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    
    if isempty(answer)
        answer=defaultanswer;
        cancel=1;
    end
end



if isempty(surveydata)
    surveydata=survey_data_cl();
end

if p.Results.Voyage_only>0
    Snapshot=surveydata.Snapshot;
    Stratum=surveydata.Stratum;
    Transect=surveydata.Transect;
else
    SurveyName=surveydata.SurveyName;
    Voyage=surveydata.Voyage;
    
    if ~isnan(str2double(answer{1}))
        Snapshot=floor(str2double(answer{1}));
    else
        Snapshot=surveydata.Snapshot;
        warning('Invalid Snapshot number.');
    end
    
    Stratum=answer{2};
    
    if ~isnan(str2double(answer{3}))
        Transect=floor(str2double(answer{3}));
    else
        Transect=surveydata.Transect;
        warning('Invalid Transect number');
    end
end

end