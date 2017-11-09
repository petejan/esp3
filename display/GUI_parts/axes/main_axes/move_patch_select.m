function move_patch_select(src,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);


axes_panel_comp=getappdata(main_figure,'Axes_panel');
patch_obj=src;
ah=axes_panel_comp.main_axes;

if isempty(patch_obj.Vertices)||~ismember(curr_disp.CursorMode,{'Normal'})
    return;
end

current_fig=main_figure;

if strcmp(current_fig.SelectionType,'normal')
    cp = ah.CurrentPoint;
    x0 = cp(1,1);
    y0 = cp(1,2);
    
%     x_lim=get(ah,'xlim');
%     y_lim=get(ah,'ylim');
    xdata=trans_obj.get_transceiver_pings();
    ydata=trans_obj.get_transceiver_samples();
    
    dx_patch=nanmax(patch_obj.Vertices(:,1))-nanmin(patch_obj.Vertices(:,1));
    dy_patch=nanmax(patch_obj.Vertices(:,2))-nanmin(patch_obj.Vertices(:,2));
    
    replace_interaction(current_fig,'interaction','WindowButtonMotionFcn','id',2,'interaction_fcn',@wbmcb,'Pointer','fleur');
    replace_interaction(current_fig,'interaction','WindowButtonUpFcn','id',2,'interaction_fcn',@wbucb,'Pointer','fleur');
end
    function wbmcb(~,~)
        cp = ah.CurrentPoint;
        x1 = cp(1,1);
        y1 = cp(1,2);
        
        
        d_move=[x1 y1]-[x0 y0];
        
        new_vert=patch_obj.Vertices+repmat(d_move,4,1);
        
        if any(new_vert(:,1)<xdata(1))
            new_vert(:,1)=[xdata(1) xdata(1)+dx_patch xdata(1)+dx_patch xdata(1)];
        end
        
        if any(new_vert(:,1)>xdata(end))
            new_vert(:,1)=[xdata(end)-dx_patch xdata(end) xdata(end) xdata(end)-dx_patch];
        end
        
        if any(new_vert(:,2)<ydata(1))
            new_vert(:,2)=[ydata(1) ydata(1) ydata(1)+dy_patch ydata(1)+dy_patch];
        end
        
        if any(new_vert(:,2)>ydata(end))
            new_vert(:,2)=[ydata(end)-dy_patch ydata(end)-dy_patch ydata(end) ydata(end)];
        end
        
        patch_obj.Vertices=new_vert;
        
        x0=x1;
        y0=y1;

        
    end

    function wbucb(~,~)
        
    replace_interaction(current_fig,'interaction','WindowButtonMotionFcn','id',2);
    replace_interaction(current_fig,'interaction','WindowButtonUpFcn','id',2);
    curr_disp.UIupdate=1;
    end
end


