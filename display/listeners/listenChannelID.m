
function listenChannelID(src,evt,main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
curr_disp.Freq=layer.Frequencies(idx_freq);
opt_panel=getappdata(main_figure,'option_tab_panel');

update_bottom_tab(main_figure);
update_bottom_tab_v2(main_figure);
update_bad_pings_tab(main_figure);
update_denoise_tab(main_figure);
update_school_detect_tab(main_figure);
update_single_target_tab(main_figure,1);
update_track_target_tab(main_figure);
update_processing_tab(main_figure);
update_display_tab(main_figure);

load_calibration_tab(main_figure,opt_panel);

load_info_panel(main_figure);

range=trans_obj.get_transceiver_range();
[~,y_lim_min]=nanmin(abs(range-curr_disp.R_disp(1)));
[~,y_lim_max]=nanmin(abs(range-curr_disp.R_disp(2)));

if curr_disp.R_disp(2)==Inf
    y_lim_max=numel(range);
end

clear_regions(main_figure,{},{'main' 'mini'});

delete(findobj(axes_panel_comp.main_axes,'Tag','SelectLine','-or','Tag','SelectArea'));

set(axes_panel_comp.main_axes,'ylim',[y_lim_min y_lim_max]);

update_mini_ax(main_figure,1);

curr_disp.setActive_reg_ID({});
update_reglist_tab(main_figure,1);
display_regions(main_figure,'both');
display_bottom(main_figure);
display_tracks(main_figure);
display_lines(main_figure);
set_alpha_map(main_figure,'main_or_mini',{'main','mini'});
order_stacks_fig(main_figure);
display_info_ButtonMotionFcn([],[],main_figure,1);

end

