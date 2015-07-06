function inter_region_create(src,main_figure,mode,func)

obj=gco;

axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;

if strcmp(src.SelectionType,'normal')&&axes_panel_comp.main_echo==obj
    
    u=get(ah,'children');
    
    for ii=1:length(u)
        if (isa(u(ii),'matlab.graphics.primitive.Line')||isa(u(ii),'matlab.graphics.chart.primitive.Line'))...
                &&~strcmp(get(u(ii),'tag'),'track')...
                &&~strcmp(get(u(ii),'tag'),'bottom')...
                &&~strcmp(get(u(ii),'tag'),'region')
            delete(u(ii));
        end
    end
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
        idx_r=[];
        idx_pings=[];
        return;
    end
    src.Pointer = 'cross';
    
    x_box=xinit;
    y_box=yinit;
    
    src.WindowButtonMotionFcn = @wbmcb;
    src.WindowButtonUpFcn = @wbucb;
    
    axes(ah);
    hold on;
    hp=plot(x_box,y_box,'color','k','linewidth',1);
    
    
else
    src.WindowButtonMotionFcn = '';
    src.WindowButtonUpFcn = '';
    src.Pointer = 'arrow';
    idx_r=[];
    idx_pings=[];
         
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
        
        axes(ah);
        hold on;
        hp=plot(x_box,y_box,'color','k','linewidth',1);
        drawnow;
        
    end

    function wbucb(src,~)
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        src.Pointer = 'arrow';
        
        y_min=nanmin(y_box);
        y_max=nanmax(y_box);
        
        y_min=nanmax(y_min,ydata(1));
        y_max=nanmin(y_max,ydata(end));
        
        x_min=nanmin(x_box);
        x_min=nanmax(xdata(1),x_min);
        
        x_max=nanmax(x_box);
        x_max=nanmin(xdata(end),x_max);
        
        idx_pings=find(xdata<=x_max&xdata>=x_min);
        idx_r=find(ydata<=y_max&ydata>=y_min);
        reset_disp_info(main_figure);
        feval(func,main_figure,idx_r,idx_pings);

    end

end