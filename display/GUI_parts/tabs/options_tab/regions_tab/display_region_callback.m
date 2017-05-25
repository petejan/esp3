function display_region_callback(~,~,main_figure,ID)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

reg_curr=trans_obj.get_region_from_Unique_ID(ID);

switch reg_curr.Reference
    case 'Line'
        line_obj=layer.get_first_line();
    otherwise
        line_obj=[];
end

reg_curr.display_region(trans_obj,'main_figure',main_figure,'line_obj',line_obj);

end