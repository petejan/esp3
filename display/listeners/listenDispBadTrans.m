function listenDispBadTrans(src,listdata,main_figure)
main_menu=getappdata(main_figure,'main_menu');
set(main_menu.disp_bad_trans,'checked',listdata.AffectedObject.DispBadTrans);
set_alpha_map(main_figure);
update_mini_ax(main_figure,0);
end