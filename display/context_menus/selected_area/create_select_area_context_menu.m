function create_select_area_context_menu(select_plot,main_figure)

context_menu=uicontextmenu(main_figure);
select_plot.UIContextMenu=context_menu;

uimenu(context_menu,'Label','Apply Bottom Detection V1 ','Callback',{@apply_bottom_detect_cback,select_plot,main_figure,'v1'});
uimenu(context_menu,'Label','Apply Bottom Detection V2 ','Callback',{@apply_bottom_detect_cback,select_plot,main_figure,'v2'});

end

function apply_bottom_detect_cback(~,~,select_plot,main_figure,ver)
update_algos(main_figure);
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
r=layer.Transceivers(idx_freq).Data.get_range();


idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));

[~,idx_r_min]=nanmin(abs(r-nanmin(select_plot.YData)));

[~,idx_r_max]=nanmin(abs(r-nanmax(select_plot.YData)));

switch ver
    case 'v2'
        alg_name='BottomDetectionV2';
    case 'v1'
        alg_name='BottomDetection';
end
show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
layer.Transceivers(idx_freq).apply_algo(alg_name,'load_bar_comp',load_bar_comp,'idx_r',idx_r_min:idx_r_max,'idx_pings',idx_pings);
curr_disp.Bot_changed_flag=1; 
hide_status_bar(main_figure);


setappdata(main_figure,'Layer',layer);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
display_bottom(main_figure);
order_stacks_fig(main_figure);

end