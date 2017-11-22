function brush_off_soundings_callback(~,~,select_plot,main_figure,set_bad)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);



switch class(select_plot)
    case 'region_cl'
        idx_r=select_plot.Idx_r;
        idx_pings=select_plot.Idx_pings;
    otherwise
        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        idx_r=round(nanmin(select_plot.YData)):round(nanmax(select_plot.YData));
end



bottom_idx=trans_obj.get_bottom_idx();
idx_brush=intersect(idx_pings,find((bottom_idx>=idx_r(1))&bottom_idx<=idx_r(end)));
bottom_idx(idx_brush)=nan;

old_bot=trans_obj.Bottom;
bot=old_bot;

bot.Sample_idx=bottom_idx;
if set_bad>0
    bot.Tag(idx_brush)=0;
end

trans_obj.setBottom(bot);

curr_disp.Bot_changed_flag=1;
setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);

add_undo_bottom_action(main_figure,trans_obj,old_bot,bot);

display_bottom(main_figure);
set_alpha_map(main_figure);

end