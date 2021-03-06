function replace_sub_data(data_obj,field,data_mat)

if isempty(data_mat)
    return;
end

[idx,found]=find_field_idx(data_obj,field);

if found==0
    data_obj.add_sub_data(field,data_mat);
    return;
else
    nb_pings=data_obj.get_nb_pings_per_file();
    nb_samples=repmat(data_obj.Nb_samples,1,length(nb_pings));
    data_mat_cell=divide_mat(data_mat,nb_samples,nb_pings);
    
    for ii=1:length(data_mat_cell)
        data_obj.SubData(idx).Memap{ii}.Data.(lower(deblank(field)))=single(data_mat_cell{ii});
    end
end
end
