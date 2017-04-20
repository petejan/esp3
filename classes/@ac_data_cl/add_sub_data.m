function add_sub_data(data_obj,field,data_mat)
if isempty(data_mat)
    return;
end


if ~iscell(field)
    field={field};
end

if ~iscell(data_mat)
    data_mat={data_mat};
end

for i=1:length(field)
    fieldname=field{i};
    data_obj.remove_sub_data(fieldname);
    
    nb_pings=data_obj.get_nb_pings_per_file();
    nb_samples=repmat(data_obj.Nb_samples,1,length(nb_pings));
    data_mat_cell=divide_mat(data_mat{i},nb_samples,nb_pings);
  
    new_sub_data=sub_ac_data_cl(fieldname,data_obj.MemapName,data_mat_cell);
    data_obj.SubData=[data_obj.SubData new_sub_data]; 
    data_obj.Fieldname=[data_obj.Fieldname {new_sub_data.Fieldname}];
    data_obj.Type=[data_obj.Type {new_sub_data.Type}];

end


end