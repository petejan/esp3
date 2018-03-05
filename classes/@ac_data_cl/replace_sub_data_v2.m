function replace_sub_data_v2(data_obj,field,data_mat,idx_pings,default_value)

if isempty(data_mat)
    return;
end

[idx,found]=find_field_idx(data_obj,field);

if found==0
    data_obj.init_sub_data(field,default_value);
    [idx,~]=find_field_idx(data_obj,field);
end
nb_pings=data_obj.get_nb_pings_per_file();
nb_samples=repmat(data_obj.Nb_samples,1,length(nb_pings));

[data_mat_cell,idx_pings_cell]=divide_mat_v2(data_mat,nb_samples,nb_pings,idx_pings);

for ii=1:length(data_mat_cell)
    if ~isempty(idx_pings_cell{ii})
        data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field)))(:,idx_pings_cell{ii})=data_mat_cell{ii}/data_obj.SubData(idx).ConvFactor;
    end
    data_mat_cell{ii}=[];
end

end
