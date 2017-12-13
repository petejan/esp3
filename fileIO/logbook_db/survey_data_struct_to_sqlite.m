function survey_data_struct_to_sqlite(path_f,surv_data_struct)

dir_raw=dir(fullfile(path_f,'*.raw'));

dir_asl=dir(fullfile(path_f,'*A'));

list_raw=union({dir_raw(:).name},{dir_asl(:).name});
nb_files=length(list_raw);

db_file=fullfile(path_f,'echo_logbook.db');

if ~(exist(db_file,'file')==2)
    initialize_echo_logbook_dbfile(path_f,1)
end

dbconn=sqlite(db_file,'connect');
createlogbookTable(dbconn);

for i=1:nb_files
    file_curr=deblank(list_raw{i});
    idx_file_xml=find(strcmpi(file_curr,surv_data_struct.Filename));
    survdata_temp=survey_data_cl();
    dbconn.exec(sprintf('delete from logbook where Filename like "%s"',file_curr));
    
    if ~isempty(idx_file_xml)
        for is=idx_file_xml
            survdata_temp=surv_data_struct.SurvDataObj{is};
            start_time=survdata_temp.StartTime;
            end_time=survdata_temp.EndTime;
            
            if isnan(start_time)||(start_time==0)
                start_time=get_start_date_from_raw(fullfile(path_f,list_raw{i}));
            end
            
            if isnan(end_time)||(end_time==1)
                [~,end_time]=start_end_time_from_file(fullfile(path_f,list_raw{i}));
            end
            survdata_temp.surv_data_to_logbook_db(dbconn,list_raw{i},'StartTime',start_time,'EndTime',end_time);
            
        end
    else
        [start_time,end_time]=start_end_time_from_file(fullfile(path_f,list_raw{i}));
        survdata_temp.surv_data_to_logbook_db(dbconn,list_raw{i},'StartTime',start_time,'EndTime',end_time);
        
    end
    
    
end

idx_sname=find(~strcmp(surv_data_struct.SurveyName,''),1);
if ~isempty(idx_sname)
    surv_name=surv_data_struct.SurveyName{idx_sname};
else
    surv_name=survdata_temp.SurveyName;
end

idx_vname=find(~strcmp(surv_data_struct.Voyage,''),1);
if ~isempty(idx_vname)
    voy=surv_data_struct.Voyage{idx_vname};
else
    voy=survdata_temp.Voyage;
end

dbconn.exec('delete from survey ');
dbconn.insert('survey',{'SurveyName' 'Voyage' },{surv_name voy});

close(dbconn);


end

