function filenames=get_files_from_db(dbconn,surv_data_obj)

p = inputParser;
addRequired(p,'dbconn',@(obj) isa(obj,'sqlite'));
addRequired(p,'surv_data_obj',@(obj) isa(obj,'survey_data_cl'));
parse(p,dbconn,surv_data_obj);


switch deblank(surv_data_obj.Type)
    case ''
        filenames=dbconn.fetch(sprintf('select Filename from logbook where  Snapshot=%.0f and Stratum is "%s" and Transect=%.0f',...
            surv_data_obj.Snapshot,surv_data_obj.Stratum,surv_data_obj.Transect));
    otherwise
        filenames=dbconn.fetch(sprintf('select Filename from logbook where Type is "%s" and Snapshot=%.0f and Stratum is "%s" and Transect=%.0f',...
            surv_data_obj.Type,surv_data_obj.Snapshot,surv_data_obj.Stratum,surv_data_obj.Transect));

end


end