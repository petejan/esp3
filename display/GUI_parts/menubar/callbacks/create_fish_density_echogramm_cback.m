function create_fish_density_echogramm_cback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);

sv=trans_obj.Data.get_datamat('sv');

TS=-50;

data_mat=10.^(sv-TS)/10;
trans_obj.Data.add_sub_data('fishdensity',data_mat);

curr_disp.setField('fishdensity');
setappdata(main_figure,'Curr_disp',curr_disp);

end