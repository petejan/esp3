function move_patch_select(src,~,main_figure)


axes_panel_comp=getappdata(main_figure,'Axes_panel');
patch_obj=src;
ah=axes_panel_comp.main_axes;

if isempty(patch_obj.Vertices)
    return;
end

current_fig=main_figure;
wbmcb_ori=current_fig.WindowButtonMotionFcn;

if strcmp(current_fig.SelectionType,'normal')
    cp = ah.CurrentPoint;
    x0 = cp(1,1);
    y0 = cp(1,2);
    x_lim=get(ah,'xlim');
    y_lim=get(ah,'ylim');
    
    
    dx_patch=nanmax(patch_obj.Vertices(:,1))-nanmin(patch_obj.Vertices(:,1));
    dy_patch=nanmax(patch_obj.Vertices(:,2))-nanmin(patch_obj.Vertices(:,2));
    
    current_fig.WindowButtonMotionFcn = @wbmcb;
    current_fig.WindowButtonUpFcn = @wbucb;
end
    function wbmcb(~,~)
        cp = ah.CurrentPoint;
        x1 = cp(1,1);
        y1 = cp(1,2);
        
        
        d_move=[x1 y1]-[x0 y0];
        
        new_vert=patch_obj.Vertices+repmat(d_move,4,1);
        
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
        
        patch_obj.Vertices=new_vert;
        
        x0=x1;
        y0=y1;
        drawnow;
        
    end

    function wbucb(~,~)
        
        current_fig.WindowButtonMotionFcn = wbmcb_ori;
        current_fig.WindowButtonUpFcn = '';
      
    end
end


