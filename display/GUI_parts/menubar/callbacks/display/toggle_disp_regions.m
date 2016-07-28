function toggle_disp_regions(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

main_axes=axes_panel_comp.main_axes;

u=findobj(main_axes,'tag','region','-or','tag','region_text');
set(u,'visible',curr_disp.DispReg);
order_stacks_fig(main_figure);

    
end

