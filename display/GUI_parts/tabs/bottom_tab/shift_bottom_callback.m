function shift_bottom_callback(~,~,main_figure)
    
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
bottom_tab_comp=getappdata(main_figure,'Bottom_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
layer.Transceivers(idx_freq).shift_bottom(get(bottom_tab_comp.Shift_bot_sl,'value'));

update_axis_panel(main_figure,0);
update_mini_ax(main_figure);


end