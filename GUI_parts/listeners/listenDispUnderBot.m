function listenDispUnderBot(src,listdata,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
set(display_tab_comp.disp_under_bot,'value',strcmpi(listdata.AffectedObject.DispUnderBottom,'off'));
set_alpha_map(main_figure);
end