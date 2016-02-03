function listenDispReg(src,listdata,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
set(display_tab_comp.disp_reg,'value',listdata.AffectedObject.DispReg);
toggle_disp_regions(main_figure);
end