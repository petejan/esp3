function toggle_disp_regions(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');

%main_axes_tot=[axes_panel_comp.main_axes display_tab_comp.mini_ax];
main_axes_tot=axes_panel_comp.main_axes;

for iax=1:length(main_axes_tot)
    main_axes=main_axes_tot(iax);
    u=findobj(main_axes,'tag','region','-or','tag','region_text');
    set(u,'visible',curr_disp.DispReg);
end
order_stacks_fig(main_figure);

end

