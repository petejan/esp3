function toggle_disp_lines(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

main_axes=axes_panel_comp.main_axes;

u=findobj(main_axes,'tag',lines);

if curr_disp.DispLines>0
    set(u,'visible','on');
else
    set(u,'visible','off');
end


    
end
