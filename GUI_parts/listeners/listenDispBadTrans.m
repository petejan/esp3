function listenDispBadTrans(src,listdata,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
set(display_tab_comp.disp_bad_trans,'value',listdata.AffectedObject.DispBadTrans);
set_alpha_map(main_figure);
end