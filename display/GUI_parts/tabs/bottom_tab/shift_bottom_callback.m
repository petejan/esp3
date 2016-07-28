function shift_bottom_callback(~,~,main_figure)
    
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
bottom_tab_comp=getappdata(main_figure,'Bottom_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
layer.Transceivers(idx_freq).shift_bottom(get(bottom_tab_comp.Shift_bot_sl,'value'));

display_bottom(main_figure);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');

end