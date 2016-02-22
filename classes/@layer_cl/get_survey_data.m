function survey_data=get_survey_data(layer_obj,varargin)

p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'Idx',1,@isnumeric);

parse(p,layer_obj,varargin{:});
results=p.Results;

if length(layer_obj.SurveyData)>=results.Idx
    survey_data=layer_obj.SurveyData{results.Idx};
else
    survey_data=[];
end


end