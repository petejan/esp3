function hand_region_create(src,main_figure,func)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
src.Pointer = 'ibeam';
ah=axes_panel_comp.main_axes;


if strcmp(src.SelectionType,'normal')
    
    clear_lines(ah);
        switch curr_disp.Cmap
        case 'esp2'
            col_line='w';
        otherwise
            col_line='k';
    end
    
    xdata=double(get(axes_panel_comp.main_echo,'XData'));
    ydata=double(get(axes_panel_comp.main_echo,'YData'));
    
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    trans=layer.Transceivers(idx_freq);
    bot=trans.Bottom;

    Number=trans.Data.get_numbers();
    nb_pings=length(Number);
    
    if isempty(bot.Range)
        bot.Range=nan(1,nb_pings);
        bot.Sample_idx=nan(1,nb_pings);
    end
    
    cp = ah.CurrentPoint;
    u=1;
    xinit=nan(1,1e4);
    yinit=nan(1,1e4);
    xinit(1) = cp(1,1);
    yinit(1)=cp(1,2);
    
    if xinit(1)<xdata(1)||xinit(1)>xdata(end)||yinit(1)<1||yinit(1)>ydata(end)
        return
    end
    axes(ah);
    hold on;
    hp=line(xinit,yinit,'color',col_line,'linewidth',1);
    txt=text(cp(1,1),cp(1,2),sprintf('%.2f m',cp(1,2)),'color',col_line);
    
    src.WindowButtonMotionFcn = @wbmcb;
    src.WindowButtonUpFcn = @wbucb;
end
    function wbmcb(~,~)  
        cp = ah.CurrentPoint;
        u=u+1;
        xinit(u) = cp(1,1);
        yinit(u) = cp(1,2);
        str_txt=sprintf('%.2f m',cp(1,2));
        set(hp,'XData',xinit,'YData',yinit);
        set(txt,'position',[cp(1,1) cp(1,2) 0],'string',str_txt);
        drawnow;
    end

    function wbucb(src,~)
        
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        src.Pointer = 'arrow';
        delete(txt);
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
        if length(poly_pings)<=2
            return;
        end
        poly_pings=[poly_pings poly_pings(1)];
        poly_r=[poly_r poly_r(1)];
        reset_disp_info(main_figure);
        clear_lines(ah)
        
        [idx_r_ori,idx_ping_ori]=get_ori(layer,curr_disp,axes_panel_comp.main_echo);
        
        feval(func,main_figure,poly_r+idx_r_ori-1,poly_pings+idx_ping_ori-1);
        

    end
end
