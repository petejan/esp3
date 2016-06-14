function layers_out_cell=sort_per_survey_data(layers_in)


output=layers_in.list_layers_survey_data();

[~,~,strat_vec_num]=unique(output.Stratum);
[~,~,voy_vec_num]=unique(output.Voyage);
[~,~,surv_name_vec_num]=unique(output.SurveyName);

mat_surv_data=[surv_name_vec_num';voy_vec_num';output.Snapshot;strat_vec_num';output.Transect]';
[~,unique_trans,trans_ids]=unique(mat_surv_data,'rows');

id_lays_out_cell=cell(1,length(unique_trans));

for i_out=1:length(id_lays_out_cell)
    id_lays_out_cell{i_out}=output.Layer_idx(trans_ids==unique_trans(i_out));
end

nb_cell_out=0;
cell_out={};
while ~isempty(id_lays_out_cell)
nb_cell_out=nb_cell_out+1;
idx_temp=cellfun(@(x) ~isempty(intersect(id_lays_out_cell{1},x)),id_lays_out_cell);
cell_out{nb_cell_out}=unique([id_lays_out_cell{idx_temp}]);
id_lays_out_cell(idx_temp)=[];
end


layers_out_cell=cell(1,length(cell_out));

for ilay=1:length(layers_out_cell)
    layers_out_cell{ilay}=layers_in(cell_out{ilay});
end



end