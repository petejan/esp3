function remove_ST_cback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj=layer.get_trans(curr_disp.Freq);

trans_obj.rm_ST();
trans_obj.Data.remove_sub_data('singletarget');

curr_disp.Freq=curr_disp.Freq;

end