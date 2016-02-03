function create_WC_region_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);

if found==0
    return;
end

trans_obj=layer.Transceivers(idx_freq);
reg_wc=trans_obj.create_WC_region();
trans_obj.add_region(reg_wc);
update_display(main_figure,0);