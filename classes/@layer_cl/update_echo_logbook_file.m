function update_echo_logbook_file(layer_obj)
file_name=fullfile(layer_obj.PathToFile,'echo_logbook.csv');
if exist(file_name,'file')==0
    initialize_echo_logbook_file(layer_obj.PathToFile);
end

surv_data_struct=import_survey_data(layer_obj.PathToFile,'echo_logbook.csv');

list_raw=ls(fullfile(layer_obj.PathToFile,'*.raw'));

nb_files=size(list_raw,1);

copyfile(fullfile(layer_obj.PathToFile,'echo_logbook.csv'),fullfile(layer_obj.PathToFile,'echo_logbook_saved.csv'));

try
    
    fid=fopen(file_name,'w+');
    if fid==-1
        fclose('all');
        fid=fopen(file_name,'w+');
        if fid==-1
            warning('Could not update the .csv logbook file');
            return;
        end
    end
    
    fprintf(fid,'Datapath,Voyage,SurveyName,Filename,Snapshot,Stratum,Transect,StartTime,EndTime\n');
    
    for i=1:nb_files
        file_curr=list_raw(i,:);
        idx_file=find(strcmpi(file_curr,layer_obj.Filename),1);
        idx_file_cvs=find(strcmpi(file_curr,surv_data_struct.Filename),1);
        
        if isempty(idx_file)
            if ~isempty(idx_file_cvs)
                
                for is=idx_file_cvs
                    
                    if~isnan(surv_data_struct.StartTime(is))
                        startTime=surv_data_struct.StartTime(is);
                    else
                        startTime=0;
                    end
                    
                    if~isnan(surv_data_struct.EndTime(is))
                        endTime=surv_data_struct.EndTime(is);
                    else
                        endTime=1;
                    end
                   
                    if isnumeric(surv_data_struct.Stratum{is})
                        surv_data_struct.Stratum{is}=num2str(surv_data_struct.Stratum{is},'%.0f');
                    end
                    
                    fprintf(fid,'%s,%s,%s,%s,%.0f,%s,%.0f,%d,%d\n',...
                        layer_obj.PathToFile,...
                        surv_data_struct.Voyage{is},...
                        surv_data_struct.SurveyName{is},...
                        strrep(file_curr,' ',''),...
                        surv_data_struct.Snapshot(is),...
                        surv_data_struct.Stratum{is},...
                        surv_data_struct.Transect(is),...
                        startTime,...
                        endTime);
                        
                    

                end
                
            else
                fprintf(fid,'%s, , ,%s,0, ,0,0,1\n',layer_obj.PathToFile,strrep(file_curr,' ',''));
            end
            
        else
            survey_data_temp=layer_obj.SurveyData;
            
            if isempty(survey_data_temp)
                endTime=datestr(layer_obj.Transceivers(1).Data.Time(end),'yyyymmddHHMMSS');
                startTime=datestr(layer_obj.Transceivers(1).Data.Time(1),'yyyymmddHHMMSS');
                fprintf(fid,'%s, , ,%s,0, ,0,%s,%s\n',layer_obj.PathToFile,strrep(file_curr,' ',''),startTime,endTime);
            else
                for  i_cell=1:length(survey_data_temp)
                    if ~isempty(survey_data_temp{i_cell})
                        fprintf(fid,'%s,%s,%s,%s,%.0f,%s,%.0f,%s,%s\n',...
                            layer_obj.PathToFile,...
                            survey_data_temp{i_cell}.Voyage,...
                            survey_data_temp{i_cell}.SurveyName,...
                            strrep(file_curr,' ',''),...
                            survey_data_temp{i_cell}.Snapshot,...
                            survey_data_temp{i_cell}.Stratum,...
                            survey_data_temp{i_cell}.Transect,...
                            datestr(survey_data_temp{i_cell}.StartTime,'yyyymmddHHMMSS'),...
                            datestr(survey_data_temp{i_cell}.EndTime,'yyyymmddHHMMSS'));

                    else
                        fprintf(fid,'%s, , ,%s,0, ,0,0,1\n',layer_obj.PathToFile,strrep(file_curr,' ',''));
                    end
                end
                
            end
        end
         
    end   
    fclose(fid);
    delete(fullfile(layer_obj.PathToFile,'echo_logbook_saved.csv'));
catch err
    disp(err);
    warning('Error when updating the logbook. Restoring previous version...') ;
    fclose('all');
    copyfile(fullfile(layer_obj.PathToFile,'echo_logbook_saved.csv'),fullfile(layer_obj.PathToFile,'echo_logbook.csv'));
    
end


end