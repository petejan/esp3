function listenDispLines(src,listdata,main_figure)
main_menu=getappdata(main_figure,'main_menu');
set(main_menu.disp_lines,'checked',listdata.AffectedObject.DispLines);
toggle_disp_lines(main_figure);
end