function surv_results_to_csv(surv_obj,file_id)

if ~isempty(surv_obj.SurvOutput)
    props=properties(surv_obj.SurvOutput);
    for i=1:length(props)
        if~strcmp(props{i},'regionsIntegrated')
            struct2csv(surv_obj.SurvOutput.(props{i}),[file_id '_' props{i} '.csv'],1);
        end
    end
    
end

end