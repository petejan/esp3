function edit_bottom(src,evt,main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;

clear_lines(ah)


switch lower(curr_disp.Cmap)
    case 'esp2'
        line_col='g';
    otherwise
        line_col='r';

end

xdata=double(get(axes_panel_comp.main_echo,'XData'));
ydata=double(get(axes_panel_comp.main_echo,'YData'));
idx_freq=find_freq_idx(layer,curr_disp.Freq);


nb_pings=length(layer.Transceivers(idx_freq).Data.Time);
nb_samples=length(layer.Transceivers(idx_freq).Data.get_range());
bot=layer.Transceivers(idx_freq).Bottom;


if isempty(bot.Range)
    bot.Range=nan(1,nb_pings);
    bot.Sample_idx=nan(1,nb_pings);
end
xinit=nan(1,nb_pings);
yinit=nan(1,nb_pings);

cp = ah.CurrentPoint;
xinit(1) =cp(1,1);
yinit(1)=cp(1,2);
u=1;
if xinit(1)<xdata(1)||xinit(1)>xdata(end)||yinit(1)<1||yinit(1)>ydata(end)
    return
end

hp=plot(ah,xinit,xinit,'color',line_col,'linewidth',1);
src.WindowButtonMotionFcn = @wbmcb;
if strcmp(src.SelectionType,'normal')
    src.WindowButtonUpFcn = @wbucb;
elseif strcmp(src.SelectionType,'alt')
    src.WindowButtonUpFcn = @wbucb_alt;
end
    function wbmcb(~,~)
        u=u+1;
        cp=ah.CurrentPoint;
        xinit(u)=cp(1,1);
        yinit(u)=cp(1,2);

        set(hp,'XData',xinit,'YData',yinit);
    end

    function wbucb(src,~)
        
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        src.Pointer = 'arrow';
        delete(hp);
        xinit(isnan(xinit))=[];
        yinit(isnan(yinit))=[];
        x_rem=xinit>xdata(end)|xinit<xdata(1);
        y_rem=yinit>ydata(end)|yinit<ydata(1);
        
        xinit(x_rem|y_rem)=[];
        yinit(x_rem|y_rem)=[];
        
        [x_f,IA,~] = unique(xinit);
        y_f=yinit(IA);
        [idx_r_ori,idx_ping_ori]=get_ori(layer,curr_disp,axes_panel_comp.main_echo);
        
        if length(x_f)>1
            for i=1:length(x_f)-1
                [~, idx_bot]=nanmin(abs(x_f(i)-xdata));
                [~, idx_bot_1]=nanmin(abs(x_f(i+1)-xdata));
                [~,idx_r]=nanmin(abs(y_f(i)-ydata));
                [~,idx_r1]=nanmin(abs(y_f(i+1)-ydata));
                
                idx_bot_tot=(idx_bot:idx_bot_1)+idx_ping_ori-1;

                bot.Range(idx_bot_tot)=linspace(y_f(i),y_f(i+1),length(idx_bot_tot));
                bot.Sample_idx(idx_bot_tot)=round(linspace(idx_r+idx_r_ori-1,idx_r1+idx_r_ori-1,length(idx_bot_tot)));
            end
        elseif length(x_f)==1
            [~, idx_bot]=nanmin(abs(x_f-xdata));
            [~,idx_r]=nanmin(abs(y_f-ydata));
            bot.Sample_idx(idx_bot+idx_ping_ori-1)=idx_r+idx_r_ori-1;
            bot.Range(idx_bot+idx_ping_ori-1)=y_f;
        end
          
     end_bottom_edit();
        
    end

    function wbucb_alt(src,~)
        
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        src.Pointer = 'arrow';
        delete(hp);
        
        x_min=nanmin(xinit);
        x_max=nanmax(xinit);
        
        [~,idx_ping_ori]=get_ori(layer,curr_disp,axes_panel_comp.main_echo);
        
        [~, idx_min]=nanmin(abs(x_min-xdata));
        [~, idx_max]=nanmin(abs(x_max-xdata));
        idx_pings=(idx_min:idx_max)+idx_ping_ori-1;
        bot.Range(idx_pings)=nan;
        bot.Sample_idx(idx_pings)=nan;
        end_bottom_edit();

   
    end

    function end_bottom_edit()

        xdata_real=layer.Transceivers(idx_freq).Data.get_numbers();
        ydata_real=layer.Transceivers(idx_freq).Data.get_range();
        
        layer.Transceivers(idx_freq).Bottom=bot;
        setappdata(main_figure,'Layer',layer);
        reset_disp_info(main_figure);
        if strcmp(curr_disp.Cmap,'esp2')
            col='y'; % ESP2's colormap is 'black background' so the bottom line is drawn in yellow
        elseif strcmp(curr_disp.Cmap,'ek500')
            col='g'; % Simrad sounders use a green bottom line
        else
            col='k';
        end
        
        display_bottom(xdata_real,ydata_real,layer.Transceivers(idx_freq).Bottom.Sample_idx,axes_panel_comp,curr_disp.DispBottom,col);
        set_alpha_map(main_figure);

    end
end
