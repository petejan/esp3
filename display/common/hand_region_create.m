function hand_region_create(src,main_figure,func)


layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;


if strcmp(src.SelectionType,'normal')
    
    clear_lines(ah);
    
    xdata=double(get(axes_panel_comp.main_echo,'XData'));
    ydata=double(get(axes_panel_comp.main_echo,'YData'));
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    dat=layer.Transceivers(idx_freq).Data.get_datamat('Power');
    bot=layer.Transceivers(idx_freq).Bottom;
    [nb_samples,nb_pings]=size(dat);
    
    if isempty(bot.Range)
        bot.Range=nan(1,nb_pings);
        bot.Sample_idx=nan(1,nb_pings);
        bot.Double_bot_mask=zeros(nb_samples,nb_pings);
    end
    
    cp = ah.CurrentPoint;
    xinit = cp(1,1);
    yinit=cp(1,2);
    
    if xinit<xdata(1)||xinit>xdata(end)||yinit<1||yinit>ydata(end)
        return
    end
    axes(ah);
    hold on;
    hp=plot(xinit,xinit,'color','k','linewidth',1);
    
    src.WindowButtonMotionFcn = @wbmcb;
    src.WindowButtonUpFcn = @wbucb;
end
    function wbmcb(~,~)
        
        cp = ah.CurrentPoint;
        
        xinit = [xinit,cp(1,1)];
        yinit = [yinit,cp(1,2)];
        
        delete(hp);
        axes(ah);
        hold on;
        hp=plot(xinit,yinit,'color','k','linewidth',1);
        drawnow;
    end

    function wbucb(src,~)
        
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        src.Pointer = 'arrow';
        delete(hp);
        x_data_disp=linspace(xdata(1),xdata(end),length(xdata));
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
        if length(poly_pings)<=2
            return;
        end
        poly_pings=[poly_pings poly_pings(1)];
        poly_r=[poly_r poly_r(1)];
        reset_disp_info(main_figure);
        clear_lines(ah)
        feval(func,main_figure,poly_r,poly_pings);
        

    end
end
