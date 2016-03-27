function update_echo_logbook_file(layers_obj,varargin)

p = inputParser;

ver_fmt=@(x) ischar(x);

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'SurveyName','',ver_fmt);
addParameter(p,'Voyage','',ver_fmt);
parse(p,layers_obj,varargin{:});

results=p.Results;

if isempty(find(strcmp(p.UsingDefaults,'Voyage'),1))
    voy=results.Voyage;
else
    voy='';
end


if isempty(find(strcmp(p.UsingDefaults,'SurveyName'),1))
    surv_name=results.SurveyName;
else
    surv_name= '';
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
        
        fprintf(fid,'Voyage,SurveyName,Filename,Snapshot,Stratum,Transect,StartTime,EndTime\n');
        
        for i=1:nb_files
            f_processed=0;
            file_curr=deblank(list_raw(i,:));
            idx_file=find(strcmpi(file_curr,file_lay),1);
            idx_file_cvs=find(strcmpi(file_curr,surv_data_struct.Filename));
            
            if isempty(idx_file)
                if ~isempty(idx_file_cvs)
                    
                    for is=idx_file_cvs
                        
                        survdata_temp=surv_data_struct.SurvDataObj{is};
                        start_time=survdata_temp.StartTime;
                        end_time=survdata_temp.EndTime;
                        
                        
                        if isnan(start_time)||(start_time==0)
                            start_time=get_start_date_from_raw(surv_data_struct.Filename{is});
                        end
                        
                        if isnan(end_time)||(end_time==1)
                            [~,end_time]=start_end_time_from_file(fullfile(path_lay{1},list_raw(i,:)));
                        end
                        
                        
                        if ~strcmp(voy,'')
                            survdata_temp.Voyage=voy;
                        end
                        
                        if ~strcmp(surv_name,'')
                            survdata_temp.SurveyName=surv_name;
                        end
                        
                        f_processed=1;
                        survdata_temp.surv_data_to_logbook_str(fid,list_raw(i,:),'StartTime',start_time,'EndTime',end_time); 
                    end
                    
                else
                    
                    [start_time,end_time]=start_end_time_from_file(fullfile(path_lay{1},list_raw(i,:)));
                    survdata_temp=survey_data_cl('Voyage',voy,'SurveyName',surv_name);
                    survdata_temp.surv_data_to_logbook_str(fid,list_raw(i,:),'StartTime',start_time,'EndTime',end_time); 
                    f_processed=1;
                end
                
            else
                survey_data_temp=layer_obj.SurveyData;
                [start_file_time,end_file_time]=layer_obj.get_time_bound_files();
                ifi=find(strcmp(file_curr,file_lay));
                
                if isempty(survey_data_temp)
                    survey_data_temp={[]};
                end
                
                for  i_cell=1:length(survey_data_temp)
                    if ~isempty(survey_data_temp{i_cell})
                        survdata_temp=survey_data_temp{i_cell};
                        if ~strcmp(voy,'')
                            survdata_temp.Voyage=voy;
                        end
                        
                        if ~strcmp(surv_name,'')
                            survdata_temp.SurveyName=surv_name;
                        end
                       
                        start_time=survdata_temp.StartTime;
                        end_time=survdata_temp.EndTime;
                        
                        if (end_file_time(ifi)<start_time||start_file_time(ifi)>(end_time))
                            continue;
                        end
                        
                        if start_time~=0
                            start_time=nanmax(start_time,start_file_time(ifi));
                        end
                        
                        if end_time~=1
                            end_time=nanmin(end_time,end_file_time(ifi));
                        end
                        
                        f_processed=1;
                        survdata_temp.surv_data_to_logbook_str(fid,list_raw(i,:),'StartTime',start_time,'EndTime',end_time); 
                    end
               
                end
                if f_processed==0
                    survdata_temp=survey_data_cl('Voyage',voy,'SurveyName',surv_name);
                    end_time=layer_obj.Transceivers(1).Data.Time(end);
                    start_time=layer_obj.Transceivers(1).Data.Time(1);
                    f_processed=1;
                    survdata_temp.surv_data_to_logbook_str(fid,list_raw(i,:),'StartTime',start_time,'EndTime',end_time); 
                end
            end
            if f_processed==0
                disp('Pb in logbook...')
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