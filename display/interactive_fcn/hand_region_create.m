function hand_region_create(main_figure,func)

layer=getappdata(main_figure,'Layer');
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
clear_lines(ah);
switch curr_disp.Cmap
    case 'esp2'
        col_line='w';
    otherwise
        col_line='k';
end

idx_freq=find_freq_idx(layer,curr_disp.Freq);

xdata=layer.Transceivers(idx_freq).get_transceiver_pings();
ydata=layer.Transceivers(idx_freq).Data.get_range();


cp = ah.CurrentPoint;
u=1;
xinit=nan(1,1e4);
yinit=nan(1,1e4);
xinit(1) = cp(1,1);
yinit(1)=cp(1,2);

xdata=layer.Transceivers(idx_freq).get_transceiver_pings();
ydata=layer.Transceivers(idx_freq).Data.get_range();

x_lim=get(ah,'xlim');
y_lim=get(ah,'ylim');

if xinit(1)<x_lim(1)||xinit(1)>xdata(end)||yinit(1)<y_lim(1)||yinit(1)>y_lim(end)
    return;
end


axes(ah);
hold on;
hp=line(xinit,yinit,'color',col_line,'linewidth',1);
txt=text(cp(1,1),cp(1,2),sprintf('%.2f m',cp(1,2)),'color',col_line);

main_figure.WindowButtonMotionFcn = @wbmcb;
main_figure.WindowButtonUpFcn = @wbucb;

    function wbmcb(~,~)
        cp = ah.CurrentPoint;
        u=u+1;
        xinit(u) = cp(1,1);
        yinit(u) = cp(1,2);
        str_txt=sprintf('%.2f m',cp(1,2));
        if isvalid(hp)
            set(hp,'XData',xinit,'YData',yinit);
        else
            hp=plot(ah,xinit,yinit,'color',col_line,'linewidth',1);
        end
        
        if isvalid(txt)
            set(txt,'position',[cp(1,1) cp(1,2) 0],'string',str_txt);
        else
            txt=text(cp(1,1),cp(1,2),sprintf('%.2f m',cp(1,2)),'color',col_line);
        end
        drawnow;
    end

    function wbucb(main_figure,~)
        
        main_figure.WindowButtonMotionFcn = '';
        main_figure.WindowButtonUpFcn = '';
        
        x_data_disp=linspace(xdata(1),xdata(end),length(xdata));
        xinit(isnan(xinit))=[];
        yinit(isnan(yinit))=[];
        xinit(xinit>xdata(end))=xdata(end);
        xinit(xinit<xdata(1))=xdata(1);
        
        yinit(yinit>ydata(end))=ydata(end);
        yinit(yinit<ydata(1))=ydata(1);
        
        poly_r=nan(size(yinit));
        poly_pings=nan(size(xinit));
        for i=1:length(xinit)
            [~,poly_pings(i)]=nanmin(abs(xinit(i)-double(x_data_disp)));
            [~,poly_r(i)]=nanmin(abs(yinit(i)-double(ydata)));
            
        end
        clear_lines(ah)
        delete(txt);
        if length(poly_pings)<=2
            return;
        end
        poly_pings=[poly_pings poly_pings(1)];
        poly_r=[poly_r poly_r(1)];
        reset_disp_info(main_figure);

        feval(func,main_figure,poly_r,poly_pings);
        curr_disp.CursorMode='Normal';
        
        main_figure.Pointer = 'arrow';
    end
end
