function surv_data_to_logbook_str(surv_data_obj,fid,filename,varargin)

p = inputParser;

addRequired(p,'surv_data_obj',@(x) isa(x,'survey_data_cl'));
addRequired(p,'fid',@isnumeric);
addRequired(p,'filename',@ischar);
addParameter(p,'StartTime',0,@isnumeric);
addParameter(p,'EndTime',1,@isnumeric);
parse(p,surv_data_obj,fid,filename,varargin{:});

if p.Results.StartTime==0
    st=get_start_date_from_raw(filename);
else
    st=datestr(p.Results.StartTime,'yyyymmddHHMMSS');
end

if p.Results.EndTime==1
    et='1';
else
    et=datestr(p.Results.EndTime,'yyyymmddHHMMSS');
end

fprintf(fid,'%s,%s,%s,%.0f,%s,%.0f,%s,%s\n',...
    surv_data_obj.Voyage,...
    surv_data_obj.SurveyName,...
    strrep(filename,' ',''),...
    surv_data_obj.Snapshot,...
    surv_data_obj.Stratum,...
    surv_data_obj.Transect,...
    st,...
    et);


end