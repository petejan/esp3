function create_fish_density_echogramm_cback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
display_tab_comp=getappdata(main_figure,'Display_tab');

sv=trans_obj.Data.get_datamat('sv');

TS=str2double(get(display_tab_comp.TS,'string'));

data_mat=10.^(sv-TS)/10;
trans_obj.Data.replace_sub_data('fishdensity',data_mat);

curr_disp.setField('fishdensity');
setappdata(main_figure,'Curr_disp',curr_disp);

end