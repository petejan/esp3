function curr_disp=read_config_display_xml(xml_file)    
    xml_struct=parseXML(xml_file);

    disp_node=get_childs(xml_struct,'Display');
    disp_struct=get_node_att(disp_node);
    fields=fieldnames(disp_struct);
    curr_disp=curr_state_disp_cl();
    
    for ifi=1:length(fields)
 
        val=sscanf([disp_struct.(fields{ifi}) ';'],'%f;');
        if ~(any(isnan(val))||isempty(val))
            curr_disp.(fields{ifi})=val;
        elseif ischar(disp_struct.(fields{ifi}))||isnumeric(disp_struct.(fields{ifi}))
            curr_disp.(fields{ifi})=disp_struct.(fields{ifi});
        end
    end
%     curr_disp.Grid_x
%     curr_disp.Grid_y
end