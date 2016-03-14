function app_path=load_config_from_xml(xml_file)

p = inputParser;
addRequired(p,'xml_file',@(obj) isa(obj,'char'));
parse(p,xml_file);

if exist(xml_file,'file')==0
    app_path=app_path_create();
    write_config_to_xml(app_path);
    return;
end
try
    xml_struct=parseXML(xml_file);
    app_node=get_childs(xml_struct,'AppPath');
    app_path=get_node_att(app_node);
catch
    disp('Could not read XML config file. Creating a standard one');
    app_path=app_path_create();
    write_config_to_xml(app_path);
end

end