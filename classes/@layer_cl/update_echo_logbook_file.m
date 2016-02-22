function update_echo_logbook_file(layer_obj,varargin)

p = inputParser;

ver_fmt=@(x) ischar(x);

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'SurveyName',' ',ver_fmt);
addParameter(p,'Voyage',' ',ver_fmt);
parse(p,layer_obj,varargin{:});

results=p.Results;

if isempty(find(strcmp(p.UsingDefaults,'Voyage'),1))
    voy=results.Voyage;
else
    voy=' ';
end


if isempty(find(strcmp(p.UsingDefaults,'SurveyName'),1))
    surv_name=results.SurveyName;
else
    surv_name= ' ';
end



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
                    
                    if strcmp(voy,' ')
                        voy_temp=surv_data_struct.Voyage{is};
                    else
                        voy_temp=voy;
                    end
                    
                    if strcmp(surv_name,' ')
                        surv_name_temp=surv_data_struct.SurveyName{is};
                    else
                        surv_name_temp=surv_name;
                    end
                    
                    fprintf(fid,'%s,%s,%s,%s,%.0f,%s,%.0f,%.0f,%.0f\n',...
                        layer_obj.PathToFile,...
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
                fprintf(fid,'%s,%s,%s,%s,0, ,0,%.0f,1\n',...
                    layer_obj.PathToFile,...
                    voy,...
                    surv_name,...
                    strrep(file_curr,' ',''),...
                    start_date);
            end
            
        else
            survey_data_temp=layer_obj.SurveyData;
            
            if isempty(survey_data_temp)
                
                endTimeStr=datestr(layer_obj.Transceivers(1).Data.Time(end),'yyyymmddHHMMSS');
                startTimeStr=datestr(layer_obj.Transceivers(1).Data.Time(1),'yyyymmddHHMMSS');
                fprintf(fid,'%s,%s,%s,%s,0, ,0,%s,%s\n',layer_obj.PathToFile,voy,surv_name,strrep(file_curr,' ',''),startTimeStr,endTimeStr);
            else
                for  i_cell=1:length(survey_data_temp)
                    if ~isempty(survey_data_temp{i_cell})
                        if strcmp(voy,' ')
                            voy_temp=survey_data_temp{i_cell}.Voyage;
                        else
                            voy_temp=voy;
                        end
                        
                        if strcmp(surv_name,' ')
                            surv_name_temp=survey_data_temp{i_cell}.SurveyName;
                        else
                            surv_name_temp=surv_name;
                        end
                        
                        endTimeStr=datestr(survey_data_temp{i_cell}.StartTime,'yyyymmddHHMMSS');
                        startTimeStr=datestr(survey_data_temp{i_cell}.StartTime,'yyyymmddHHMMSS');
                        fprintf(fid,'%s,%s,%s,%s,%.0f,%s,%.0f,%s,%s\n',...
                            layer_obj.PathToFile,...
                            voy_temp,...
                            surv_name_temp,...
                            strrep(file_curr,' ',''),...
                            survey_data_temp{i_cell}.Snapshot,...
                            survey_data_temp{i_cell}.Stratum,...
                            survey_data_temp{i_cell}.Transect,...
                            endTimeStr,...
                            startTimeStr);
                        
                    else
                        endTimeStr=datestr(layer_obj.Transceivers(1).Data.Time(end),'yyyymmddHHMMSS');
                        startTimeStr=datestr(layer_obj.Transceivers(1).Data.Time(1),'yyyymmddHHMMSS');
                        fprintf(fid,'%s,%s,%s,%s,0, ,0,%s,%s\n',layer_obj.PathToFile,voy,surv_name,strrep(file_curr,' ',''),startTimeStr,endTimeStr);
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