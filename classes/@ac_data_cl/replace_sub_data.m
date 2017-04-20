function replace_sub_data(data_obj,field,data_mat)
if isempty(data_mat)
    return;
end

nb_pings=data_obj.get_nb_pings_per_file();
nb_samples=repmat(length(data_obj.get_samples()),1,length(nb_pings));
data_mat_cell=divide_mat(data_mat,nb_samples,nb_pings);
[idx,found]=find_field_idx(data_obj,field);

if found==0
    data_obj.add_sub_data(field,data_mat);
    return;
else
    for ii=1:length(data_mat_cell)
        data_obj.SubData(idx).Memap{ii}.Data.(field)=single(data_mat_cell{ii});
    end
end
end
