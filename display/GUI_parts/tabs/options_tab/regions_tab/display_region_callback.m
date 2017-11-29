function display_region_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,~]=layer.get_trans(curr_disp);

for i=1:length(curr_disp.Active_reg_ID)
    
    reg_curr=trans_obj.get_region_from_Unique_ID(curr_disp.Active_reg_ID{i});
    
    if isempty(reg_curr)
        return;
    end
    
    switch reg_curr.Reference
        case 'Line'
            line_obj=layer.get_first_line();
        otherwise
            line_obj=[];
    end
    
    if ismember('svdenoised',trans_obj.Data.Fieldname)
        field='svdenoised';
    else
        field='sv';
    end
    
    reg_curr.display_region(trans_obj,'main_figure',main_figure,'line_obj',line_obj,'field',field);
end
end