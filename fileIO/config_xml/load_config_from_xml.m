function [app_path,curr_disp,algo_vec]=load_config_from_xml(xml_file)

p = inputParser;
addRequired(p,'xml_file',@(obj) isa(obj,'char'));
parse(p,xml_file);

if exist(xml_file,'file')==0
    disp('Could not find XML config file. Creating a standard one');
    app_path=app_path_create();
    curr_disp=curr_state_disp_cl();
    algo_vec=init_algos();
    write_config_to_xml(app_path,curr_disp,algo_vec);
    return;
end

try
    xml_struct=parseXML(xml_file);
    app_node=get_childs(xml_struct,'AppPath');
    app_path=get_node_att(app_node);
    
    
    disp_node=get_childs(xml_struct,'Display');
    disp_struct=get_node_att(disp_node);
    fields=fieldnames(disp_struct);
    curr_disp=curr_state_disp_cl();
    for ifi=1:length(fields)
        val=disp_struct.(fields{ifi});
        if isnan(str2double(val))
            curr_disp.(fields{ifi})=val;
        elseif ischar(curr_disp.(fields{ifi}))
            curr_disp.(fields{ifi})=str2double(val);
        end
    end
    
    algo_node=get_childs(xml_struct,'algos');
    Algos=get_algos(algo_node);
    algo_vec(length(Algos))=algo_cl();
    
    for ial=1:length(algo_vec)
       algo_vec(ial)=algo_cl('Name',Algos{ial}.Name,'Varargin',Algos{ial}.Varargin);  
    end

catch
    disp('Could not read XML config file. Creating a standard one');
    app_path=app_path_create();
    curr_disp=curr_state_disp_cl();
    algo_vec=init_algos();
    write_config_to_xml(app_path,curr_disp,algo_vec);
end

end