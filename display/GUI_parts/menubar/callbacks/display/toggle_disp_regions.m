function toggle_disp_regions(main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

mini_ax_comp=getappdata(main_figure,'Mini_axes');
main_axes_tot=[axes_panel_comp.main_axes mini_ax_comp.mini_ax];

for iax=1:length(main_axes_tot)
    main_axes=main_axes_tot(iax);
    u_reg_line=findobj(main_axes,'tag','region','-and','Type','line');
    set(u_reg_line,'visible',curr_disp.DispReg);
    
    u_reg_image=findobj(main_axes,'tag','region','-and',{'Type','Image','-or','Type','Patch'});
    set(u_reg_image,'visible',curr_disp.DispReg);
   
end

 %order_stacks_fig(main_figure);