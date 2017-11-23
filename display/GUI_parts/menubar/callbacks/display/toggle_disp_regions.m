function toggle_disp_regions(main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

[~,main_axes_tot,~,~,~]=get_axis_from_cids(main_figure,union({'main' 'mini'},layer.ChannelID));
for iax=1:length(main_axes_tot)
    main_axes=main_axes_tot(iax);
    u_reg_line=findobj(main_axes,'tag','region','-and','Type','line');
    set(u_reg_line,'visible',curr_disp.DispReg);
    
    u_reg_image=findobj(main_axes,'tag','region','-and',{'Type','Image','-or','Type','Patch'});
    set(u_reg_image,'visible',curr_disp.DispReg);
   
end

 %order_stacks_fig(main_figure);