function missing_files=find_survey_data_db(file_layer)

[path_f,files,term]=cellfun(@fileparts,file_layer,'UniformOutput',0);

missing_files={};

[unique_paths,~,idx_unique]=unique(path_f);

for ip=1:length(unique_paths)
    files_temp=files(idx_unique==ip);
    term_file=term(idx_unique==ip);
    db_file=fullfile(unique_paths{ip},'echo_logbook.db');
    if ~(exist(db_file,'file')==2)
        initialize_echo_logbook_dbfile(unique_paths{ip},0)
    end
    
    dbconn=sqlite(db_file,'connect');
    for i=1:length(files_temp)
        curr_file_data=dbconn.fetch(sprintf('select * from logbook where Filename like "%s%s"',files_temp{i},term_file{i}));
        nb_data=size(curr_file_data,1);
        
        for id=1:nb_data
            missing_file_temp=dbconn.fetch(sprintf('select Filename from logbook where  Snapshot=%.0f and Stratum like "%s" and Transect=%.0f',curr_file_data{id,2},curr_file_data{id,3},curr_file_data{id,4}));
            missing_files=union(missing_files,fullfile(unique_paths{ip},missing_file_temp));
        end
        
    end
    
end

missing_files=unique(missing_files);
missing_files=setdiff(missing_files,file_layer);


end
