function add_survey_data_db(layers)

for ilay=1:length(layers)
    	surv_data={};
    for i=1:length(layers(ilay).Filename)
         surv_data_temp=get_file_survey_data_from_db(layers(ilay).Filename{i});
         surv_data=[surv_data surv_data_temp];
    end
    layers(ilay).set_survey_data(surv_data);
end

end