function listenDispLines(src,listdata,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
set(display_tab_comp.disp_lines,'value',listdata.AffectedObject.DispLines);
toggle_disp_lines(main_figure);
end