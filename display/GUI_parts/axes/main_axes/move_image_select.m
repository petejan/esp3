function move_image_select(src,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
idx_freq=find_freq_idx(layer,curr_disp.Freq);


axes_panel_comp=getappdata(main_figure,'Axes_panel');
image_obj=src;
ah=axes_panel_comp.main_axes;

if isempty(image_obj.XData)||~strcmp(curr_disp.CursorMode,'Normal')
    return;
end

current_fig=main_figure;
wbmcb_ori=current_fig.WindowButtonMotionFcn;

if strcmp(current_fig.SelectionType,'normal')
    cp = ah.CurrentPoint;
    x0 = cp(1,1);
    y0 = cp(1,2);
    

    xdata=layer.Transceivers(idx_freq).get_transceiver_pings();
    ydata=layer.Transceivers(idx_freq).Data.get_range();
    
    dx_image=nanmax(image_obj.XData(:))-nanmin(image_obj.XData(:));
    dy_image=nanmax(image_obj.YData(:))-nanmin(image_obj.YData(:));
    
    current_fig.WindowButtonMotionFcn = @wbmcb;
    current_fig.WindowButtonUpFcn = @wbucb;
end
    function wbmcb(~,~)
        cp = ah.CurrentPoint;
        x1 = cp(1,1);
        y1 = cp(1,2);
        

        new_XData=image_obj.XData+(x1-x0);
        new_YData=image_obj.YData+(y1-y0);
        
        if any(new_XData<xdata(1))
            new_XData=[xdata(1) xdata(1)+dx_image xdata(1)+dx_image xdata(1)];
        end
        
        if any(new_XData>xdata(end))
            new_XData=[xdata(end)-dx_image xdata(end) xdata(end) xdata(end)-dx_image];
        end
        
        if any(new_YData<ydata(1))
            new_YData=[ydata(1) ydata(1) ydata(1)+dy_image ydata(1)+dy_image];
        end
        
        if any(new_YData>ydata(end))
           new_YData=[ydata(end)-dy_image ydata(end)-dy_image ydata(end) ydata(end)];
        end
        
        image_obj.XData=new_XData;
        image_obj.YData=new_YData;
        
        x0=x1;
        y0=y1;
        
    end

    function wbucb(~,~)
        
        current_fig.WindowButtonMotionFcn = wbmcb_ori;
        current_fig.WindowButtonUpFcn = '';
      
    end
end


