function add_survey_data(layers,survey_data_struct)
%'Voyage' 'SurveyName' 'Filename' 'Snapshot' 'Stratum' 'Transect' 'StartTime' 'EndTime'
files={};
nb_files=0;

surv_data=cell(1,length(layers));
ilay_tot=[];
for ilay=1:length(layers)
    [~,files_temp]=layers(ilay).get_path_files();
    ilay_tot=[ilay_tot ilay*ones(1,length(files_temp))];
    files=[files files_temp];
    nb_files=nb_files+length(layers(ilay).Filename);
end

[idx_files_layer,idx_loaded,~]=find_survey_data(files,survey_data_struct);


for i=1:length(idx_loaded)
    if isempty(idx_loaded{i})
        continue;
    end

    idx_lay=ilay_tot(idx_files_layer{i});
    
    for il=1:length(idx_lay)
        
        survdata_temp=survey_data_struct.SurvDataObj{idx_loaded{i}(il)};
        start_time=survdata_temp.StartTime;
        end_time=survdata_temp.EndTime;
        
        [start_file_time,end_file_time]=layers(idx_lay(il)).get_time_bound_files();
        
        [~,files_lay]=layers(idx_lay(il)).get_path_files();
        
        ifile=find(strcmp(files_lay,survey_data_struct.Filename(idx_loaded{i}(il))));
        
        if start_time==0
            start_time=start_file_time(ifile);
        end
        
        if end_time==1
            end_time=end_file_time(ifile);
        end
        
        survdata_temp.StartTime=start_time;
        survdata_temp.EndTime=end_time;
        
        surv_data{idx_lay(il)}{length(surv_data{idx_lay(il)})+1}=survdata_temp;
    end
end

for ilay=1:length(layers)
    layers(ilay).set_survey_data(surv_data{ilay});
end

end