function update_echo_logbook_file_manually(file_full,survey_data)%one full file name and one survey data

[path_f,file_name,file_ext]=fileparts(file_full);
file_lay=[file_name file_ext];

surv_data_struct=load_logbook_to_struct(path_f);
list_raw=ls(fullfile(path_f,'*.raw'));
nb_files=size(list_raw,1);

copyfile(fullfile(path_f,'echo_logbook.csv'),fullfile(path_f,'echo_logbook_saved.csv'));

try
    fid=fopen(fullfile(path_f,'echo_logbook.csv'),'w+');
    if fid==-1
        fclose('all');
        fid=fopen(fullfile(path_f,'echo_logbook.csv'),'w+');
        if fid==-1
            delete(fullfile(path_f,'echo_logbook_saved.csv'));
            warning('Could not update the .csv logbook file');
            return;
        end
    end
    
    fprintf(fid,'Voyage,SurveyName,Filename,Snapshot,Stratum,Transect,StartTime,EndTime\n');
    
    for i=1:nb_files
        file_curr=deblank(list_raw(i,:));
        isfile=strcmpi(file_curr,file_lay);
        idx_file_cvs=find(strcmpi(file_curr,surv_data_struct.Filename));
        
        if isfile==0
            if ~isempty(idx_file_cvs)
                for is=idx_file_cvs    
                    survdata_temp=surv_data_struct.SurvDataObj{is};
                    start_time=survdata_temp.StartTime;
                    end_time=survdata_temp.EndTime;
                    
                    if isnan(start_time)||(start_time==0)
                        start_time=get_start_date_from_raw(fullfile(path_f,list_raw(i,:)));
                    end
                    
                    if isnan(end_time)||(end_time==1)
                        [~,end_time]=start_end_time_from_file(fullfile(path_f,list_raw(i,:)));
                    end
                    
                    survdata_temp.surv_data_to_logbook_str(fid,list_raw(i,:),'StartTime',start_time,'EndTime',end_time);
                end
            else
                [start_time,end_time]=start_end_time_from_file(fullfile(path_f,list_raw(i,:)));
                survdata_temp=survey_data_cl();
                survdata_temp.surv_data_to_logbook_str(fid,list_raw(i,:),'StartTime',start_time,'EndTime',end_time);
            end
            
            
        else
            survdata_temp=survey_data;
            
            if isempty(survdata_temp)
                survdata_temp=survey_data_cl();
            end
            
            start_time=survdata_temp.StartTime;
            end_time=survdata_temp.EndTime;
            
            if isnan(start_time)||(start_time==0)
                start_time=get_start_date_from_raw(list_raw(i,:));
            end
            
            if isnan(end_time)||(end_time==1)
                [~,end_time]=start_end_time_from_file(fullfile(path_f,list_raw(i,:)));
            end
            
            survdata_temp.surv_data_to_logbook_str(fid,list_raw(i,:),'StartTime',start_time,'EndTime',end_time);
        end
    end
    
    
    fclose(fid);
    delete(fullfile(path_f,'echo_logbook_saved.csv'));
catch err
    disp(err.message);
    warning('Error when updating the logbook. Restoring previous version...') ;
    fclose('all');
    copyfile(fullfile(path_f,'echo_logbook_saved.csv'),fullfile(path_f,'echo_logbook.csv'));
    delete(fullfile(path_f,'echo_logbook_saved.csv'));
end
end

