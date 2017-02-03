function update_echo_logbook_dbfile(layers_obj,varargin)

p = inputParser;

ver_fmt=@(x) ischar(x);

addRequired(p,'layers_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'SurveyName','',ver_fmt);
addParameter(p,'Voyage','',ver_fmt);
addParameter(p,'Filename','',@ischar);
addParameter(p,'SurveyData',survey_data_cl.empty(),@(obj) isa(obj,'survey_data_cl'));
parse(p,layers_obj,varargin{:});

results=p.Results;



% for ilay=1:length(layers_obj)
%     [path_lay,~]=layers_obj(ilay).get_path_files();
% %     pathtofile=union(pathtofile,path_lay);
%     files_lays=union(files_lays,layers_obj(ilay).Filename);
% end
% if ~strcmp(p.Results.Filename,'')
%     [new_path,~,~]=fileparts(p.Results.Filename);
%     pathtofile=union(pathtofile,new_path);
% end

for ilay=1:length(layers_obj)
    
    [path_lay,~]=layers_obj(ilay).get_path_files();
    path_lay=unique(path_lay);
    files_lay=layers_obj(ilay).Filename;
    for ip=1:length(path_lay)
        
        path_f=path_lay{ip};
        curr_files=files_lay(cellfun(@(x) ~isempty(strfind(x,path_f)),files_lay));
        db_file=fullfile(path_f,'echo_logbook.db');
        if ~(exist(db_file,'file')==2)
            initialize_echo_logbook_dbfile(path_f,0)
        end
        
        dbconn=sqlite(db_file,'connect');
        
        files_logbook=dbconn.fetch('select Filename from logbook order by StartTime');
        survey_data=dbconn.fetch('select * from survey');
        
        dbconn.close();
        
        
        if ~isempty(survey_data{1})
            if ~any(strcmp(p.UsingDefaults,'SurveyName'))
                surv_name=results.SurveyName;
            else
                surv_name=survey_data{1};
            end
        else
            surv_name=results.SurveyName;
        end
        
        if ~isempty(survey_data{2})
            if ~any(strcmp(p.UsingDefaults,'Voyage'))
                voy=results.Voyage;
            else
                voy=survey_data{2};
            end
        else
            voy=results.Voyage;
        end
        
        
        dir_raw=dir(fullfile(path_f,'*.raw'));
        dir_asl=dir(fullfile(path_f,'*A'));
        list_raw=union({dir_raw([dir_raw(:).isdir]==0).name},{dir_asl([dir_asl(:).isdir]==0).name});
        
        
        new_files=setdiff(list_raw,files_logbook);
        
        dbconn=sqlite(db_file,'connect');
        
        for i=1:length(new_files)
            fprintf('Adding file %s to logbook\n',new_files{i});
            [start_time,end_time]=start_end_time_from_file(fullfile(path_f,new_files{i}));
            
            survdata_temp=survey_data_cl('Voyage',voy,'SurveyName',surv_name);
            
            survdata_temp.surv_data_to_logbook_db(dbconn,new_files{i},'StartTime',start_time,'EndTime',end_time);
        end
        
        
        for i=1:length(curr_files)
            [~,file_curr_temp,end_temp]=fileparts(curr_files{i});
            file_curr_short=[file_curr_temp end_temp];
            file_curr=curr_files{i};
            f_processed=0;
            
            if strcmp(file_curr,p.Results.Filename)
                survey_data_temp=p.Results.SurveyData;
            else
                survey_data_temp=layers_obj(ilay).SurveyData;
            end
            
            [start_file_time,end_file_time]=layers_obj(ilay).get_time_bound_files();
            file_lay=layers_obj(ilay).Filename;
            ifi=find(strcmp(file_curr,file_lay));
            
            if isempty(survey_data_temp)
                survey_data_temp={[]};
            end
            
            if ~iscell(survey_data_temp)
                survey_data_temp={survey_data_temp};
            end
            
            for  i_cell=1:length(survey_data_temp)
                if ~isempty(survey_data_temp{i_cell})
                    survdata_temp=survey_data_temp{i_cell};
                    survdata_temp.Voyage=voy;
                    survdata_temp.SurveyName=surv_name;
                    
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
                    survdata_temp.surv_data_to_logbook_db(dbconn,file_curr_short,'StartTime',start_time,'EndTime',end_time);
                end
                
                
                if f_processed==0
                    survdata_temp=survey_data_cl('Voyage',voy,'SurveyName',surv_name);
                    end_time=layers_obj(ilay).Transceivers(1).Data.Time(end);
                    start_time=layers_obj(ilay).Transceivers(1).Data.Time(1);
                    survdata_temp.surv_data_to_logbook_db(dbconn,file_curr_short,'StartTime',start_time,'EndTime',end_time);
                end
            end
            
            
        end
        
        
        dbconn.close();
        
    end
    
    
end


if ~strcmp(p.Results.Filename,'')
    [start_time,end_time]=start_end_time_from_file(p.Results.Filename);
    survdata_temp=p.Results.SurveyData;
    [path_f,file_r,end_file]=fileparts(p.Results.Filename);
    
    db_file=fullfile(path_f,'echo_logbook.db');
    
    dbconn=sqlite(db_file,'connect');
    if ~(exist(db_file,'file')==2)
        initialize_echo_logbook_dbfile(path_f,0)
    end
    survey_data=dbconn.fetch('select * from survey');
    
    
    
    if ~isempty(survey_data{1})
        if ~any(strcmp(p.UsingDefaults,'SurveyName'))
            survdata_temp.SurveyName=results.SurveyName;
        else
            survdata_temp.SurveyName=survey_data{1};
        end
    else
        survdata_temp.SurveyName=results.SurveyName;
    end
    
    if ~isempty(survey_data{2})
        if ~any(strcmp(p.UsingDefaults,'Voyage'))
            survdata_temp.Voyae=results.Voyage;
        else
            survdata_temp.Voyage=survey_data{2};
        end
    else
        survdata_temp.Voyage=results.Voyage;
    end
    dbconn.exec(sprintf('delete from logbook where Filename like "%s"',[file_r end_file]));
    survdata_temp.surv_data_to_logbook_db(dbconn,[file_r end_file],'StartTime',start_time,'EndTime',end_time);
    dbconn.close();
end





end
%%



