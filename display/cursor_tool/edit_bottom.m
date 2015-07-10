function edit_bottom(src,~,main_figure)


layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;

    
    u=get(ah,'children');
    for ii=1:length(u)
        if (isa(u(ii),'matlab.graphics.primitive.Line')||isa(u(ii),'matlab.graphics.chart.primitive.Line'))...
                &&~strcmp(get(u(ii),'tag'),'bottom')...
                &&~strcmp(get(u(ii),'tag'),'track')...
                &&~strcmp(get(u(ii),'tag'),'region')
            delete(u(ii));
        end
    end
    
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
    if strcmp(src.SelectionType,'normal')      
        src.WindowButtonUpFcn = @wbucb;
    elseif strcmp(src.SelectionType,'alt')
        src.WindowButtonUpFcn = @wbucb_alt;  
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
        
        x_rem=xinit>xdata(end)|xinit<xdata(1);
        y_rem=yinit>ydata(end)|yinit<ydata(1);
        
        xinit(x_rem|y_rem)=[];
        yinit(x_rem|y_rem)=[];
        
        [x_f,IA,~] = unique(xinit);
        y_f=yinit(IA);
        
        for i=1:length(x_f)-1
            [~, idx_bot]=nanmin(abs(x_f(i)-xdata));
            [~, idx_bot_1]=nanmin(abs(x_f(i+1)-xdata));
            [~,idx_r]=nanmin(abs(y_f(i)-ydata));
            [~,idx_r1]=nanmin(abs(y_f(i+1)-ydata));
            bot.Range(idx_bot:idx_bot_1)=linspace(y_f(i),y_f(i+1),length(idx_bot:idx_bot_1));
            bot.Sample_idx(idx_bot:idx_bot_1)=round(linspace(idx_r,idx_r1,length(idx_bot:idx_bot_1)));
        end
        
        layer.Transceivers(idx_freq).Bottom=bot;
        setappdata(main_figure,'Layer',layer);
        reset_disp_info(main_figure);
        axes_panel_comp=display_bottom(xdata,layer.Transceivers(idx_freq).Bottom.Range,axes_panel_comp,curr_disp.DispBottom);
        set_alpha_map(main_figure);
        setappdata(main_figure,'Axes_panel',axes_panel_comp);
    end

 function wbucb_alt(src,~)
        
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        src.Pointer = 'arrow';
        delete(hp);
        
        x_min=nanmin(xinit);
        x_max=nanmax(xinit);
          
        [~, idx_min]=nanmin(abs(x_min-xdata));
        [~, idx_max]=nanmin(abs(x_max-xdata));

            bot.Range(idx_min:idx_max)=nan;
            bot.Sample_idx(idx_min:idx_max)=nan;

        layer.Transceivers(idx_freq).Bottom=bot;
        setappdata(main_figure,'Layer',layer);
        reset_disp_info(main_figure);
        axes_panel_comp=display_bottom(xdata,layer.Transceivers(idx_freq).Bottom.Range,axes_panel_comp,curr_disp.DispBottom);
        set_alpha_map(main_figure);
        setappdata(main_figure,'Axes_panel',axes_panel_comp);
    end
end
