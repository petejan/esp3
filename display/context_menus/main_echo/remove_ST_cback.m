function remove_ST_cback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

trans_obj.rm_ST();
trans_obj.Data.remove_sub_data('singletarget');
curr_disp.ChannelID=layer.ChannelID{idx_freq};


end