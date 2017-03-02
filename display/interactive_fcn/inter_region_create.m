function inter_region_create(main_figure,mode,func)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;

switch main_figure.SelectionType
    case 'normal'
        
    otherwise
        curr_disp.CursorMode='Normal';
        return;
end
axes_panel_comp.bad_transmits.UIContextMenu=[];
axes_panel_comp.bottom_plot.UIContextMenu=[];
switch curr_disp.Cmap
    case 'esp2'
        col_line='w';
    otherwise
        col_line='k';
end


clear_lines(ah);

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

axes(ah);
hold on;
hp=line(x_box,y_box,'color',col_line,'linewidth',1);
txt=text(cp(1,1),cp(1,2),sprintf('%.2f m',cp(1,2)),'color',col_line);
uistack(hp,'top');

main_figure.WindowButtonMotionFcn = @wbmcb;
main_figure.WindowButtonUpFcn = @wbucb;


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
        str_txt=sprintf('%.2f m',cp(1,2));
        set(hp,'XData',x_box,'YData',y_box);
        set(txt,'position',[cp(1,1) cp(1,2) 0],'string',str_txt);
        
    end

    function wbucb(main_figure,~)
        
        main_figure.WindowButtonMotionFcn = '';
        main_figure.WindowButtonUpFcn = '';
        
        layer=getappdata(main_figure,'Layer');
        
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
                idx_pings=1:length(layer.Transceivers(idx_freq).get_transceiver_pings());
            case 'vertical'
                idx_r=1:length(layer.Transceivers(idx_freq).get_transceiver_range());
                idx_pings=idx_pings+idx_ping_ori-1;
            otherwise
                idx_r=idx_r+idx_r_ori-1;
                idx_pings=idx_pings+idx_ping_ori-1;
        end
        delete(txt);
        delete(hp);
        reset_disp_info(main_figure);
        feval(func,main_figure,idx_r,idx_pings);
        
        curr_disp.CursorMode='Normal';
       
    end

end