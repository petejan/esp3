function app_path=read_config_path_xml(xml_file)    
    xml_struct=parseXML(xml_file);
    app_node=get_childs(xml_struct,'AppPath');
    app_path=get_node_att(app_node);
    
    app_path_deflt=app_path_create();
    prop_deflt=fieldnames(app_path_deflt);
    
    for iprop =1:numel(prop_deflt)
        if~isfield(app_path,prop_deflt{iprop})
            app_path.(prop_deflt{iprop})=app_path_deflt.(prop_deflt{iprop});
        end
    end
end