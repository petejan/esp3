function surv_data_to_logbook_db(surv_data_obj,dbconn,filename,varargin)

p = inputParser;

addRequired(p,'surv_data_obj',@(x) isa(x,'survey_data_cl'));
addRequired(p,'dbconn',@(x) isa(x,'sqlite'));
addRequired(p,'filename',@ischar);
addParameter(p,'StartTime',0,@isnumeric);
addParameter(p,'EndTime',1,@isnumeric);
parse(p,surv_data_obj,dbconn,filename,varargin{:});

if p.Results.StartTime==0
    st_num=get_start_date_from_raw(filename);
else
    st_num=p.Results.StartTime;
    
end
st=datestr(st_num,'yyyy-mm-dd HH:MM:SS');

if p.Results.EndTime==1
    et_num=st_num+1/(24*60*60);
else
    et_num=p.Results.EndTime;
end

et=datestr(et_num,'yyyy-mm-dd HH:MM:SS');

snap=surv_data_obj.Snapshot;

if ~ischar(surv_data_obj.Comment)
    comm=num2str(surv_data_obj.Comment,'%.0f');
else
    comm=surv_data_obj.Comment;
end

if ~ischar(surv_data_obj.Stratum)
    strat=num2str(surv_data_obj.Stratum,'%.0f');
else
    strat=surv_data_obj.Stratum;
end

trans=surv_data_obj.Transect;
try
    %before=dbconn.fetch(sprintf('select * from logbook where Filename like "%s"',filename))
    dbconn.exec('delete from survey');
    dbconn.insert('survey',{'Voyage' 'SurveyName'},...
        {surv_data_obj.Voyage surv_data_obj.SurveyName});
    dbconn.insert('logbook',{'Filename' 'Snapshot' 'Stratum' 'Transect'  'StartTime' 'EndTime' 'Comment'},...
        {filename snap strat trans st et comm});
%     after_log=dbconn.fetch(sprintf('select * from logbook where Filename like "%s"',filename))
%     after=dbconn.fetch('select * from survey')
catch err
    disp(err.message)
end

end