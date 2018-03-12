function missing_files=find_survey_data_db(file_layer)

[path_f,files,term]=cellfun(@fileparts,file_layer,'UniformOutput',0);

missing_files={};

[unique_paths,~,idx_unique]=unique(path_f);

for ip=1:length(unique_paths)
    files_temp=files(idx_unique==ip);
    term_file=term(idx_unique==ip);
    db_file=fullfile(unique_paths{ip},'echo_logbook.db');
    
    try
        dbconn=sqlite(db_file,'connect');
        createlogbookTable(dbconn);
    catch err
        if exist('dbconn','var')>0
            close(dbconn);
        end
        if contains(err.message,'corrupt')
            warning('Sqlite echo_logbook.db file seems corrupted, we will save it anyway, but create a new one so that we can procedd with openning the files...');
            
            if isfile(db_file)
                copyfile(db_file,fullfile(unique_paths{ip},'echo_logbook_corrupt.db')) ;
                delete(db_file);
            end
            initialize_echo_logbook_dbfile(unique_paths{ip},0);
            dbconn=sqlite(db_file,'connect');
        else
            disp(err.message);
            continue;
        end
    end
    
    
    
    for i=1:length(files_temp)
        try
            curr_file_data=dbconn.fetch(sprintf('select Snapshot,Type,Stratum,Transect,StartTime,EndTime,Comment from logbook where Filename like "%s%s"',files_temp{i},term_file{i}));
        catch
            continue;
        end
        nb_data=size(curr_file_data,1);
        
        
        for id=1:nb_data
            
            if curr_file_data{id,1}==0&&(strcmp(deblank(curr_file_data{id,3}),''))&&curr_file_data{id,4}==0
                continue;
            end
            try
                missing_file_temp=dbconn.fetch(sprintf('select Filename from logbook where Snapshot=%.0f and Type is "%s" and Stratum is "%s" and Transect=%.0f',...
                    curr_file_data{id,1},curr_file_data{id,2},curr_file_data{id,3},curr_file_data{id,4}));
            catch
                missing_file_temp={};
            end
            
            missing_files=union(missing_files,fullfile(unique_paths{ip},missing_file_temp));
        end
        
    end
    close(dbconn);
end

missing_files=unique(missing_files);
missing_files=setdiff(missing_files,file_layer);


end
