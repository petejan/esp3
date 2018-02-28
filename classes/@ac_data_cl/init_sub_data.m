function init_sub_data(data_obj,field,default_value)


if ~iscell(field)
    field={field};
end


for i=1:length(field)
    fieldname=field{i};
    data_obj.remove_sub_data(fieldname);    
    nb_pings=data_obj.get_nb_pings_per_file();
    nb_samples=data_obj.Nb_samples;
    data_mat_size=cell(1,numel(nb_pings));
    
    for ifi=1:numel(nb_pings)
        data_mat_size{ifi}=[nb_samples,nb_pings(ifi)];
    end
    
    new_sub_data=sub_ac_data_cl('field',fieldname,'memapname',data_obj.MemapName,'data',data_mat_size,'default_value',default_value);
    data_obj.SubData=[data_obj.SubData new_sub_data]; 
    data_obj.Fieldname=[data_obj.Fieldname {new_sub_data.Fieldname}];
    data_obj.Type=[data_obj.Type {new_sub_data.Type}];

end


end