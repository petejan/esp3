function move_patch_mini_axis(src,evt,main_figure)

display_tab_comp=getappdata(main_figure,'Display_tab');
path_obj=display_tab_comp.patch_obj;

ah=display_tab_comp.mini_ax;

if evt.Button==1
    cp = ah.CurrentPoint;
    x_lim=get(ah,'xlim');
    y_lim=get(ah,'ylim');
    xinit=cp(1,1);
    yinit=cp(1,2);
    
    center_coord=[nanmean(path_obj.Vertices(:,1)) nanmean(path_obj.Vertices(:,2))];
    dx_patch=nanmax(path_obj.Vertices(:,1))-nanmin(path_obj.Vertices(:,1));
    dy_patch=nanmax(path_obj.Vertices(:,2))-nanmin(path_obj.Vertices(:,2));
    
    d_move=[xinit yinit]-center_coord;
    
    new_vert=path_obj.Vertices+repmat(d_move,4,1);
    
    if nansum(new_vert(:,1)<x_lim(1))>0
        new_vert(:,1)=[x_lim(1) x_lim(1)+dx_patch x_lim(1)+dx_patch x_lim(1)];
    end
    
    if nansum(new_vert(:,1)>x_lim(2))>0
        new_vert(:,1)=[x_lim(2)-dx_patch x_lim(2) x_lim(2) x_lim(2)-dx_patch];
    end
    
    if nansum(new_vert(:,2)<y_lim(1))>0
        new_vert(:,2)=[y_lim(1) y_lim(1) y_lim(1)+dy_patch y_lim(1)+dy_patch];
    end
    
    if nansum(new_vert(:,2)>y_lim(2))>0
        new_vert(:,2)=[y_lim(2)-dy_patch y_lim(2)-dy_patch y_lim(2) y_lim(2)];
    end
    
    path_obj.Vertices=new_vert;
    
    axes_panel_comp=getappdata(main_figure,'Axes_panel');
    main_axes=axes_panel_comp.main_axes;
    
    set(main_axes,'xlim',[nanmin(path_obj.Vertices(:,1)) nanmax(path_obj.Vertices(:,1))]);
    set(main_axes,'ylim',[nanmin(path_obj.Vertices(:,2)) nanmax(path_obj.Vertices(:,2))]);
    
end

