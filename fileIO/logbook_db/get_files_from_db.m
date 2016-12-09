function filenames=get_files_from_db(dbconn,surv_data_obj)

p = inputParser;
addRequired(p,'dbconn',@(obj) isa(obj,'sqlite'));
addRequired(p,'surv_data_obj',@(obj) isa(obj,'survey_data_cl'));
parse(p,dbconn,surv_data_obj);


 
 filenames=dbconn.fetch(sprintf('select Filename from logbook where  Snapshot=%.0f and Stratum like "%s" and Transect=%.0f',...
     surv_data_obj.Snapshot,surv_data_obj.Stratum,surv_data_obj.Transect));
          


end