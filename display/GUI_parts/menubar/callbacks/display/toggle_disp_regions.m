function toggle_disp_regions(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

main_axes=axes_panel_comp.main_axes;

u=get(main_axes,'children');

for ii=1:length(u)
    if strcmp(get(u(ii),'tag'),'region')
        set(u(ii),'visible',curr_disp.DispReg);
    end
end
    
end

