function inter_region_create(src,main_figure,mode,func)

obj=gco;

axes_panel_comp=getappdata(main_figure,'Axes_panel');
src.Pointer = 'ibeam';
ah=axes_panel_comp.main_axes;

if strcmp(src.SelectionType,'normal')&&axes_panel_comp.main_echo==obj
    
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
    hp=plot(x_box,y_box,'color','r','linewidth',1);
   txt=text(cp(1,1),cp(1,2),sprintf('%.2f m',cp(1,2)));
    
else
    src.WindowButtonMotionFcn = '';
    src.WindowButtonUpFcn = '';
    src.Pointer = 'arrow';
    idx_r=[];
    idx_pings=[];
         
end

    function wbmcb(~,~)

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
        
        set(hp,'XData',x_box,'YData',y_box);
        set(txt,'position',[cp(1,1) cp(1,2) 0]);
        drawnow;
        
    end

    function wbucb(src,~)
        
        delete(txt);
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        src.Pointer = 'arrow';
        
        
        layer=getappdata(main_figure,'Layer');
        curr_disp=getappdata(main_figure,'Curr_disp');
        [idx_freq,~]=layer.find_freq_idx(curr_disp.Freq);

        [idx_r_ori,idx_ping_ori]=get_ori(layer,curr_disp,axes_panel_comp.main_echo);

        
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
        
        switch mode
            case 'horizontal'
                idx_r=idx_r+idx_r_ori-1;
                idx_pings=1:length(layer.Transceivers(idx_freq).Data.get_numbers());
            case 'vertical'
                idx_r=1:length(layer.Transceivers(idx_freq).Data.get_range());
                idx_pings=idx_pings+idx_ping_ori-1;
            otherwise
                idx_r=idx_r+idx_r_ori-1;
                idx_pings=idx_pings+idx_ping_ori-1;
        end
        
        
        
        reset_disp_info(main_figure);
        clear_lines(ah)
        feval(func,main_figure,idx_r,idx_pings);
        
    end

end