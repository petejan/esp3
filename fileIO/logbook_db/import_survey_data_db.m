function surv_data_struct=import_survey_data_db(FileN)
surv_data_struct=[];


if exist(FileN,'file')==2

    
    dbconn=sqlite(FileN,'connect');
    
    data_logbook=dbconn.fetch('select * from logbook');
    data_survey=dbconn.fetch('select * from survey');
    dbconn.close();
    
    nb_lines=size(data_logbook,1);
    
    surv_data_struct=struct('Voyage',{cell(1,nb_lines)},'SurveyName',{cell(1,nb_lines)},...
        'Filename',{data_logbook(:,1)'},...
        'Snapshot',{cell2mat(data_logbook(:,2))'},...
        'Stratum',{data_logbook(:,3)'},...
        'Transect',{cell2mat(data_logbook(:,4))'},...
        'Comment',{data_logbook(:,7)'},...
        'StartTime',{cellfun(@(x) datenum(num2str(x),'yyyymmddHHMMSS'),data_logbook(:,5))'},...
        'EndTime',{cellfun(@(x) datenum(num2str(x),'yyyymmddHHMMSS'),data_logbook(:,6))'});
    
        surv_data_struct.SurveyName(:)=data_survey(1);
        surv_data_struct.Voyage(:)=data_survey(2);

   surv_data_struct.Comment(cellfun(@isempty,surv_data_struct.Comment))={''};
   
    
     [~,idx_struct]=sort(surv_data_struct.StartTime);
     field_struct=fieldnames(surv_data_struct);
     for ifi=1:length(field_struct)
         surv_data_struct.(field_struct{ifi})=surv_data_struct.(field_struct{ifi})(idx_struct);
     end
     
    
end
