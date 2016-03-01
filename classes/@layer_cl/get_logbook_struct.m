function surv_data_struct=get_logbook_struct(layer_obj)

[path_lay,~]=get_path_files(layer_obj);
surv_data_struct=load_logbook_to_struct(path_lay{1});
end