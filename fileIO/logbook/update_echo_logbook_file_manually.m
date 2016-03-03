function update_echo_logbook_file_manually(path_f,file_lay,survey_data)

[path_f_unique,~,idx_rep]=unique(path_f);

for ilay=1:length(path_f_unique)
    surv_data_struct=load_logbook_to_struct(path_f_unique{ilay});
    list_raw=ls(fullfile(path_f_unique{ilay},'*.raw'));  
    nb_files=size(list_raw,1);
    
    copyfile(fullfile(path_f_unique{ilay},'echo_logbook.csv'),fullfile(path_f_unique{ilay},'echo_logbook_saved.csv'));
    
    try
        fid=fopen(fullfile(path_f_unique{ilay},'echo_logbook.csv'),'w+');
        if fid==-1
            fclose('all');
            fid=fopen(fullfile(path_f_unique{ilay},'echo_logbook.csv'),'w+');
            if fid==-1
                delete(fullfile(path_f_unique{ilay},'echo_logbook_saved.csv'));
                warning('Could not update the .csv logbook file');
                return;
            end
        end
        
        fprintf(fid,'Voyage,SurveyName,Filename,Snapshot,Stratum,Transect,StartTime,EndTime\n');
        
        for i=1:nb_files
            file_curr=deblank(list_raw(i,:));
            idx_file=find(strcmpi(file_curr,file_lay)&idx_rep'==ilay,1);
            idx_file_cvs=find(strcmpi(file_curr,surv_data_struct.Filename));
            
            if isempty(idx_file)
                if ~isempty(idx_file_cvs)   
                    for is=idx_file_cvs'
                        if~isnan(surv_data_struct.StartTime(is))
                            startTime=surv_data_struct.StartTime(is);
                        else
                            startTime=get_start_date_from_raw(surv_data_struct.Filename{is});
                        end
                        
                        if~isnan(surv_data_struct.EndTime(is))
                            endTime=surv_data_struct.EndTime(is);
                        else
                            endTime=1;
                        end
                        
                        if isnumeric(surv_data_struct.Stratum{is})
                            surv_data_struct.Stratum{is}=num2str(surv_data_struct.Stratum{is},'%.0f');
                        end
                        
                        
                        voy_temp=surv_data_struct.Voyage{is};
                        
                        
                        surv_name_temp=surv_data_struct.SurveyName{is};

                        
                        fprintf(fid,'%s,%s,%s,%.0f,%s,%.0f,%.0f,%.0f\n',...
                            voy_temp,...
                            surv_name_temp,...
                            strrep(file_curr,' ',''),...
                            surv_data_struct.Snapshot(is),...
                            surv_data_struct.Stratum{is},...
                            surv_data_struct.Transect(is),...
                            startTime,...
                            endTime);
                    end
                    
                else
                    
                    start_date=get_start_date_from_raw(file_curr);
                    fprintf(fid,'%s,%s,%s,0, ,0,%.0f,1\n',...
                        voy,...
                        surv_name,...
                        strrep(file_curr,' ',''),...
                        start_date);
                end
                
            else
                survey_data_temp=survey_data{idx_file};
                
                if isempty(survey_data_temp)
                    survey_data_temp={[]};
                end
                
                if ~isempty(survey_data_temp)
                    if survey_data_temp.EndTime~=1
                        endTimeStr=datestr(survey_data_temp.EndTime,'yyyymmddHHMMSS');
                    else
                        endTimeStr='1';
                    end
                    
                    if survey_data_temp.StartTime~=0
                        startTimeStr=datestr(survey_data_temp.StartTime,'yyyymmddHHMMSS');
                    else
                        startTimeStr='0';
                    end
                    
                    fprintf(fid,'%s,%s,%s,%.0f,%s,%.0f,%s,%s\n',...
                        survey_data_temp.Voyage,...
                        survey_data_temp.SurveyName,...
                        strrep(file_curr,' ',''),...
                        survey_data_temp.Snapshot,...
                        survey_data_temp.Stratum,...
                        survey_data_temp.Transect,...
                        startTimeStr,...
                        endTimeStr);
                    
                else
                    endTimeStr='0';
                    startTimeStr='1';
                    fprintf(fid,'%s,%s,%s,0, ,0,%s,%s\n',' ',' ',strrep(file_curr,' ',''),startTimeStr,endTimeStr);
                end
            end
        end
        
        fclose(fid);
        delete(fullfile(path_f_unique{ilay},'echo_logbook_saved.csv'));
    catch err
        disp(err.message);
        warning('Error when updating the logbook. Restoring previous version...') ;
        fclose('all');
        copyfile(fullfile(path_f_unique{ilay},'echo_logbook_saved.csv'),fullfile(path_f_unique{ilay},'echo_logbook.csv'));
        delete(fullfile(path_f_unique{ilay},'echo_logbook_saved.csv'));
    end
end

end