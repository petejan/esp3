function add_survey_data(layers,survey_data_struct)
%'Datapath' 'Voyage' 'SurveyName' 'Filename' 'Snapshot' 'Stratum' 'Transect' 'StartTime' 'EndTime'
files={};
nb_files=0;

surv_data=cell(1,length(layers));
for ilay=1:length(layers)
    idx_files_lay(nb_files+1:nb_files+length(layers(ilay).Filename))=ilay;
    files=[files layers(ilay).Filename];
    nb_files=nb_files+length(layers(ilay).Filename);
end
idx_files=1:nb_files;

[idx_files_layer,idx_loaded,~]=find_survey_data(files,survey_data_struct);


for i=1:length(idx_loaded)
    if isempty(idx_loaded{i})
        continue;
    end
    [~,itemp]=intersect(idx_files,idx_files_layer{i});
    idx_lay=idx_files_lay(itemp);
    
    for il=1:length(idx_lay)
        start_time=survey_data_struct.StartTime(idx_loaded{i}(il));
        end_time=survey_data_struct.EndTime(idx_loaded{i}(il));
        
        [start_file_time,end_file_time]=layers(idx_lay(il)).get_time_bound_files();
        
        ifile=strcmp(survey_data_struct.Filename(idx_loaded{i}(il)),layers(idx_lay(il)).Filename);
        
        if start_time==0
            start_time=start_file_time(ifile);
        else
            start_time=datenum(num2str(start_time),'yyyymmddHHMMSS');
        end
        
        if end_time==1
            end_time=end_file_time(ifile);
        else
            end_time=datenum(num2str(end_time),'yyyymmddHHMMSS');
        end
        
        surv_temp=survey_data_cl('Voyage',survey_data_struct.Voyage{idx_loaded{i}(il)},...
            'SurveyName',survey_data_struct.SurveyName{idx_loaded{i}(il)},...
            'Snapshot',survey_data_struct.Snapshot(idx_loaded{i}(il)),...
            'Stratum',survey_data_struct.Stratum{idx_loaded{i}(il)},...
            'Transect',survey_data_struct.Transect(idx_loaded{i}(il)),...
            'StartTime',start_time,...
            'EndTime',end_time);
        
        surv_data{idx_lay(il)}{length(surv_data{idx_lay(il)})+1}=surv_temp;
    end
end

for ilay=1:length(layers)
    layers(ilay).set_survey_data(surv_data{ilay});
end

end