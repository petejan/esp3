function surv_data_struct=get_struct_from_db(path_f)


db_file=fullfile(path_f,'echo_logbook.db');
    if ~(exist(db_file,'file')==2)
        initialize_echo_logbook_dbfile(path_f,0)
    end
dbconn=sqlite(db_file,'connect');
createlogbookTable(dbconn);
surv_data_struct.Filename=dbconn.fetch('select Filename from logbook  order by StartTime');
surv_data_struct.Snapshot=cell2mat(dbconn.fetch('select Snapshot from logbook  order by StartTime'));
surv_data_struct.Stratum=dbconn.fetch('select Stratum from logbook  order by StartTime');
surv_data_struct.Type=dbconn.fetch('select Type from logbook  order by StartTime');
surv_data_struct.Transect=cell2mat(dbconn.fetch('select Transect from logbook  order by StartTime'));
surv_data_struct.Comment=dbconn.fetch('select Comment from logbook  order by StartTime');
surv_data_struct.StartTime=dbconn.fetch('select StartTime from logbook  order by StartTime');
surv_data_struct.EndTime=dbconn.fetch('select EndTime from logbook  order by StartTime');
nb_lines=length(surv_data_struct.Snapshot);

surv_data_struct.Voyage=cell(1,nb_lines);
surv_data_struct.SurveyName=cell(1,nb_lines);
surv_data_struct.Voyage(:)=dbconn.fetch('select SurveyName from survey');
surv_data_struct.SurveyName(:)=dbconn.fetch('select SurveyName from survey');

dbconn.close();



end