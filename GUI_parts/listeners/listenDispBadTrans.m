function listenDispBadTrans(src,listdata,main_figure)
main_menu=getappdata(main_figure,'main_menu');
set(main_menu.disp_bad_trans,'checked',listdata.AffectedObject.DispBadTrans);
set_alpha_map(main_figure);
display_tab_comp=getappdata(main_figure,'Display_tab');
set_alpha_map(main_figure,'echo_ax',display_tab_comp.mini_ax,'echo_im',display_tab_comp.mini_echo);
end