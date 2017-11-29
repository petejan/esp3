function display_region_fishdensity_callback(~,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
TS=str2double(get(display_tab_comp.TS,'string'));

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,~]=layer.get_trans(curr_disp);

for i=1:length(curr_disp.Active_reg_ID)
    ID=curr_disp.Active_reg_ID{i};
    reg_curr=trans_obj.get_region_from_Unique_ID(ID);
    
    switch reg_curr.Reference
        case 'Line'
            line_obj=layer.get_first_line();
        otherwise
            line_obj=[];
    end
    
    reg_curr.display_region(trans_obj,'main_figure',main_figure,'line_obj',line_obj,'field','fishdensity','TS',TS);
end
end