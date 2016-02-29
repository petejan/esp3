function update_echo_logbook_file(layers_obj,varargin)

p = inputParser;

ver_fmt=@(x) ischar(x);

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'SurveyName',' ',ver_fmt);
addParameter(p,'Voyage',' ',ver_fmt);
parse(p,layers_obj,varargin{:});

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

for ilay=1:length(layers_obj)
    layer_obj=layers_obj(ilay);
    surv_data_struct=layer_obj.get_logbook_struct();
    [path_lay,file_lay]=layer_obj.get_path_files();
    list_raw=ls(fullfile(path_lay{1},'*.raw'));
    
    nb_files=size(list_raw,1);
    
    copyfile(fullfile(path_lay{1},'echo_logbook.csv'),fullfile(path_lay{1},'echo_logbook_saved.csv'));
    
    try
        fid=fopen(fullfile(path_lay{1},'echo_logbook.csv'),'w+');
        if fid==-1
            fclose('all');
            fid=fopen(fullfile(path_lay{1},'echo_logbook.csv'),'w+');
            if fid==-1
                delete(fullfile(path_lay{1},'echo_logbook_saved.csv'));
                warning('Could not update the .csv logbook file');
                return;
            end
        end
        
        fprintf(fid,'Datapath,Voyage,SurveyName,Filename,Snapshot,Stratum,Transect,StartTime,EndTime\n');
        
        for i=1:nb_files
            file_curr=deblank(list_raw(i,:));
            idx_file=find(strcmpi(file_curr,file_lay),1);
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
                            surv_data_struct.Datapath{is},...
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
                        path_lay{1},...
                        voy,...
                        surv_name,...
                        strrep(file_curr,' ',''),...
                        start_date);
                end
                
            else
                survey_data_temp=layer_obj.SurveyData;
                [start_file_time,end_file_time]=layer_obj.get_time_bound_files();
                ifi=strcmp(file_curr,file_lay);
                
                if isempty(survey_data_temp)
                    survey_data_temp={[]};
                end
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
                        startTime=survey_data_temp{i_cell}.StartTime;
                        endTime=survey_data_temp{i_cell}.EndTime;
                        
                        if (end_file_time(ifi)<startTime||start_file_time(ifi)>(endTime))
                            continue;
                        end
                        
                        if startTime~=0
                            startTime=nanmax(startTime,start_file_time(ifi));
                        end

                        if endTime~=1
                            endTime=nanmin(endTime,end_file_time(ifi));
                        end
                        
                        endTimeStr=datestr(endTime,'yyyymmddHHMMSS');
                        startTimeStr=datestr(startTime,'yyyymmddHHMMSS');
                        
                        fprintf(fid,'%s,%s,%s,%s,%.0f,%s,%.0f,%s,%s\n',...
                            path_lay{ifi},...
                            voy_temp,...
                            surv_name_temp,...
                            strrep(file_curr,' ',''),...
                            survey_data_temp{i_cell}.Snapshot,...
                            survey_data_temp{i_cell}.Stratum,...
                            survey_data_temp{i_cell}.Transect,...
                            startTimeStr,...
                            endTimeStr);
                        
                    else
                        endTimeStr=datestr(layer_obj.Transceivers(1).Data.Time(end),'yyyymmddHHMMSS');
                        startTimeStr=datestr(layer_obj.Transceivers(1).Data.Time(1),'yyyymmddHHMMSS');
                        fprintf(fid,'%s,%s,%s,%s,0, ,0,%s,%s\n',path_lay{ifi},voy,surv_name,strrep(file_curr,' ',''),startTimeStr,endTimeStr);
                    end
                end
                
            end
            
        end
        fclose(fid);
        delete(fullfile(path_lay{1},'echo_logbook_saved.csv'));
    catch err
        disp(err);
        warning('Error when updating the logbook. Restoring previous version...') ;
        fclose('all');
        [path_lay,~]=layer_obj.get_path_files();
        copyfile(fullfile(path_lay{1},'echo_logbook_saved.csv'),fullfile(path_lay{1},'echo_logbook.csv'));
        delete(fullfile(path_lay{1},'echo_logbook_saved.csv'));
    end
end

end