function listenDispUnderBot(src,listdata,main_figure)
main_menu=getappdata(main_figure,'main_menu');
set(main_menu.disp_under_bot,'checked',listdata.AffectedObject.DispUnderBottom);
set_alpha_map(main_figure);
update_mini_ax(main_figure);

end