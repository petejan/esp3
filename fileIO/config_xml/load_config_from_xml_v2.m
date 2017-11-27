function [app_path,curr_disp,algo_vec,algo_alt]=load_config_from_xml_v2(bool_app,bool_disp,bool_algos)

[display_config_file,path_config_file,algo_config_files]=get_config_files();

if bool_app
    app_path_deflt=app_path_create();
    try
        app_path=read_config_path_xml(path_config_file);
    catch
        disp('Could not read XML path config file. Creating a standard one');
        app_path=app_path_deflt;
        write_config_path_to_xml(app_path);
    end
   
else
    app_path=[];
end

if bool_disp
    try
        curr_disp=read_config_display_xml(display_config_file);
        curr_disp.Grid_x=[0 0 0];
        curr_disp.Grid_y=0;
    catch
        disp('Could not read XML display config file. Creating a standard one');
        curr_disp=curr_state_disp_cl();
        write_config_display_to_xml(curr_disp);
    end
    
else
    curr_disp=[];
end

if bool_algos
    algo_vec(numel(algo_config_files))=algo_cl();
    algo_alt=cell(1,numel(algo_config_files));
    
    for ial=1:numel(algo_config_files)        
        try
            [algo_vec(ial),algo_alt{ial},~]=read_config_algo_xml(algo_config_files{ial});
        catch
            [~,alg_name,~]=fileparts(algo_config_files{ial});
            fprintf('Could not find XML Algo config file for %s. Creating a standard one\n',alg_name);
            algo_vec(ial)=init_algos(alg_name);
            algo_alt{ial}=algo_vec(ial);
            write_config_algo_to_xml(algo_vec(ial),{'--'},0);
        end
    end
else
    algo_vec=[];
    algo_alt={};
end

end