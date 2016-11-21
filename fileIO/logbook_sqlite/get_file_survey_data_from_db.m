function surv_data=get_file_survey_data_from_db(filename)
[path_f,filename_s,end_file]=fileparts(filename);

db_file=fullfile(path_f,'echo_logbook.db');
    if ~(exist(db_file,'file')==2)
        initialize_echo_logbook_dbfile(path_f,0)
    end
dbconn=sqlite(db_file,'connect');

data_logbook=dbconn.fetch(sprintf('select * from logbook where Filename like "%s%s" order by StartTime',filename_s,end_file));
survey_data=dbconn.fetch('select * from survey');
dbconn.close();

nb_surv_data=size(data_logbook,1);
surv_data=cell(1,nb_surv_data);

for i=1:nb_surv_data
    surv_data{i}=survey_data_cl('Voyage',survey_data{2},'SurveyName',survey_data{1},'Snapshot',data_logbook{i,2},...
        'Stratum',data_logbook{i,3},'Transect',data_logbook{i,4},...
        'StartTime',datenum(num2str(data_logbook{i,5}),'yyyymmddHHMMSS'),...
        'EndTime',datenum(num2str(data_logbook{i,6}),'yyyymmddHHMMSS'),...
        'Comment',data_logbook{i,7});
end




end