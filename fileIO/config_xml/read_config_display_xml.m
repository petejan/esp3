function curr_disp=read_config_display_xml(xml_file)    
    xml_struct=parseXML(xml_file);

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
    
end