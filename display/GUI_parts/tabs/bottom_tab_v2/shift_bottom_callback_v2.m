function shift_bottom_callback_v2(~,~,main_figure)
    
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
bottom_tab_v2_comp=getappdata(main_figure,'Bottom_tab_v2');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
layer.Transceivers(idx_freq).shift_bottom(get(bottom_tab_v2_comp.Shift_bot_sl,'value'));

display_bottom(main_figure);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');

end