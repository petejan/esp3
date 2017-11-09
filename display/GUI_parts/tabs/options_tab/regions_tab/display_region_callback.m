function display_region_callback(~,~,main_figure,ID)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
trans_obj=trans_obj;

reg_curr=trans_obj.get_region_from_Unique_ID(ID);

if isempty(reg_curr)
    return;
end

switch reg_curr.Reference
    case 'Line'
        line_obj=layer.get_first_line();
    otherwise
        line_obj=[];
end

reg_curr.display_region(trans_obj,'main_figure',main_figure,'line_obj',line_obj);

end