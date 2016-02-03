function zoom_in_callback(src,~,main_figure)
obj=gco;

axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;

if strcmp(src.SelectionType,'normal')
    mode='rectangular';
else
    mode='horizontal';
end

if axes_panel_comp.main_echo==obj
    
    clear_lines(ah)
    
    drawnow;
    xdata=get(axes_panel_comp.main_echo,'XData');
    ydata=get(axes_panel_comp.main_echo,'YData');
    cp = ah.CurrentPoint;
    
    switch mode
        case 'rectangular'
            xinit = cp(1,1);
            yinit = cp(1,2);
        case 'horizontal'
            xinit = xdata(1);
            yinit = cp(1,2);
        case 'vertical'
            xinit = cp(1,1);
            yinit = ydata(1);
    end
    
    
    if xinit<xdata(1)||xinit>xdata(end)||yinit<ydata(1)||yinit>ydata(end)
        return;
    end

    x_box=xinit;
    y_box=yinit;
    
    src.WindowButtonMotionFcn = @wbmcb;
    src.WindowButtonUpFcn = @wbucb;
    
    axes(ah);
    hold on;
    hp=plot(x_box,y_box,'color','k','linewidth',1);
  
end

    function wbmcb(~,~)
        delete(hp)
        cp = ah.CurrentPoint;
        
        
        switch mode
            case 'rectangular'
                X = [xinit,cp(1,1)];
                Y = [yinit,cp(1,2)];
            case 'horizontal'
                X = [xinit,xdata(end)];
                Y = [yinit,cp(1,2)];
            case 'vertical'
                X = [xinit,cp(1,1)];
                Y = [yinit,ydata(end)];
                
        end
        
        x_min=nanmin(X);
        x_min=nanmax(xdata(1),x_min);
        
        x_max=nanmax(X);
        x_max=nanmin(xdata(end),x_max);
        
        y_min=nanmin(Y);
        y_min=nanmax(y_min,ydata(1));
        
        y_max=nanmax(Y);
        y_max=nanmin(y_max,ydata(end));
        
        x_box=([x_min x_max  x_max x_min x_min]);
        y_box=([y_max y_max y_min y_min y_max]);
        
        
        hp=plot(x_box,y_box,'color','k','linewidth',1);
        drawnow;
        
    end

    function wbucb(src,~)
        delete(hp);
         src.WindowButtonMotionFcn = '';
         src.WindowButtonUpFcn = '';
        
        y_min=nanmin(y_box);
        y_max=nanmax(y_box);
        
        y_min=nanmax(y_min,ydata(1));
        y_max=nanmin(y_max,ydata(end));
        
        x_min=nanmin(x_box);
        x_min=nanmax(xdata(1),x_min);
        
        x_max=nanmax(x_box);
        x_max=nanmin(xdata(end),x_max);
        
        
        if x_max==x_min||y_max==y_min
            x_lim=get(ah,'XLim');
            y_lim=get(ah,'YLim');
            dx=abs(diff(x_lim));
            dy=diff(y_lim);
            
            x_lim(1)=x_lim(1)+dx/4;
            y_lim(1)=y_lim(1)+dy/4;
            x_lim(2)=x_lim(2)-dx/4;
            y_lim(2)=y_lim(2)-dy/4;
            
        else
           x_lim=[x_min x_max];
           y_lim=[y_min y_max];
        end

        set(ah,'XLim',x_lim,'YLim',y_lim);
        reset_disp_info(main_figure);

    end

end