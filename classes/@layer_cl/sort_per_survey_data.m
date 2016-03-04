function layers_out_cell=sort_per_survey_data(layers_in)

survey_data_str={};
idx_lay=[];
str_null=sprintf('Snap %d, Strat. %s, Trans. %d',...
                0,' ',0); 
i_str=0;
for il=1:length(layers_in)
    surv_data_cell=layers_in(il).SurveyData;
    for ic=1:length(surv_data_cell)
        i_str=i_str+1;
        if ~isempty(surv_data_cell{ic})
            survey_data_str{i_str}=surv_data_cell{ic}.print_survey_data();
        else
            survey_data_str{i_str}=num2str(il);
        end
        
        if ~isempty(strfind(str_null,survey_data_str{i_str}))
            survey_data_str{i_str}=num2str(il);
        end
        
        idx_lay(i_str)=il;
    end
end


id_lay=ones(1,length(layers_in));
layers_out_cell=cell(1,length(layers_in));
for ilay=1:length(layers_in)
    ilay_other=find(idx_lay~=ilay);
    ilay_current=(idx_lay==ilay);
    if id_lay(ilay)==1
        layers_out_cell{ilay}=layers_in(ilay);
        id_lay(ilay)=0;
    end
    for istr=ilay_other
        id_str=find(strcmp(survey_data_str(istr),survey_data_str(ilay_current)),1);
        if ~isempty(id_str)>0&&id_lay(idx_lay(istr))==1;
            layers_out_cell{ilay}=[layers_out_cell{ilay} layers_in(idx_lay(istr))];
            id_lay(idx_lay(istr))=0;
        end
    end
end

layers_out_cell(cellfun(@isempty,layers_out_cell))=[];

end