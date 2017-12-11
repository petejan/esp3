function toggle_disp_regions(main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

[~,main_axes_tot,~,~,~,~]=get_axis_from_cids(main_figure,union({'main' 'mini'},layer.ChannelID));
for iax=1:length(main_axes_tot)
    main_axes=main_axes_tot(iax);

    u_reg_image=findobj(main_axes,'tag','region','-and',{'Type','Image','-or','Type','Patch'});
    set(u_reg_image,'visible',curr_disp.DispReg);
   
    u_reg_polygon=findobj(main_axes,'tag','region','-and','Type','Polygon');
    switch curr_disp.DispReg
        case 'off'
            set(u_reg_polygon,'FaceAlpha',0);
        case 'on'
            set(u_reg_polygon,'FaceAlpha',0.4);
    end
end

 %order_stacks_fig(main_figure);