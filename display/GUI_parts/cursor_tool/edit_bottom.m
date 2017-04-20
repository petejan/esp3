%% edit_bottom.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |src|: TODO: write description and info on variable
% * |cbackdata|: TODO: write description and info on variable
% * |main_figure|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function edit_bottom(src,cbackdata,main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;

clear_lines(ah);

switch lower(curr_disp.Cmap)
    case 'esp2'
        line_col=[0 0.5 0];
    otherwise
        line_col='r';
        
end

idx_freq=find_freq_idx(layer,curr_disp.Freq);

xdata=layer.Transceivers(idx_freq).get_transceiver_pings();
ydata=layer.Transceivers(idx_freq).get_transceiver_samples();
%xdata=double(get(axes_panel_comp.main_echo,'XData'));
%ydata=double(get(axes_panel_comp.main_echo,'YData'));
x_lim=get(ah,'xlim');
y_lim=get(ah,'ylim');


nb_pings=length(layer.Transceivers(idx_freq).Data.Time);
%nb_samples=length(layer.Transceivers(idx_freq).get_transceiver_range());
bot=layer.Transceivers(idx_freq).Bottom;


if isempty(bot.Sample_idx)
    bot.Sample_idx=nan(1,nb_pings);
end
xinit=nan(1,nb_pings);
yinit=nan(1,nb_pings);

cp = ah.CurrentPoint;
xinit(1) =cp(1,1);
yinit(1)=cp(1,2);
u=1;
if xinit(1)<x_lim(1)||xinit(1)>xdata(end)||yinit(1)<y_lim(1)||yinit(1)>y_lim(end)
    return;
end

 wbucb_ori=src.WindowButtonUpFcn;
 wbmcb_ori=src.WindowButtonMotionFcn;

switch src.SelectionType
    case {'normal','alt','extend'}
        hp=plot(ah,xinit,yinit,'color',line_col,'linewidth',1,'Tag','bottom_temp');
       
        switch src.SelectionType
            case 'normal'
                src.WindowButtonUpFcn = @wbucb;
                src.WindowButtonMotionFcn = @wbmcb;
            case 'alt'
                src.WindowButtonUpFcn = @wbucb_alt;   
                src.WindowButtonMotionFcn = @wbmcb;
            case 'extend'
                u=u+1;
%                 enabled_obj=findobj(main_figure,'Enable','on');
%                 set(enabled_obj,'Enable','off');
                src.WindowButtonMotionFcn = @wbmcb_ext;
                src.WindowButtonDownFcn = @wbdcb_ext;
                %set(main_figure,'WindowScrollWheelFcn','');      
        end
    otherwise
        [~, idx_bot]=nanmin(abs(xinit(1)-xdata));
        [~,idx_r]=nanmin(abs(yinit(1)-ydata));
        bot.Sample_idx(idx_bot)=idx_r;
        end_bottom_edit();
end
    function wbmcb(~,~)
        u=u+1;
        cp=ah.CurrentPoint;
        xinit(u)=cp(1,1);
        yinit(u)=cp(1,2);
        display_info_ButtonMotionFcn([],[],main_figure,1);
        if isvalid(hp)
            set(hp,'XData',xinit,'YData',yinit);
        else
            hp=plot(ah,xinit,yinit,'color',line_col,'linewidth',1,'Tag','bottom_temp');
        end
    end

    function wbmcb_ext(~,~)
        cp=ah.CurrentPoint;
        xinit(u)=cp(1,1);
        yinit(u)=cp(1,2);
        display_info_ButtonMotionFcn([],[],main_figure,1);
        
        if isvalid(hp)
            set(hp,'XData',xinit,'YData',yinit);
        else
            hp=plot(ah,xinit,yinit,'color',line_col,'linewidth',1,'Tag','bottom_temp');
        end
    end

    function wbdcb_ext(~,~)
       
        switch src.SelectionType   
             case {'open' 'alt'}
%                  xinit(u)=[];
%                  yinit(u)=[];
                 wbucb(src,[]);
                 %set(main_figure,'WindowScrollWheelFcn',{@scroll_fcn_callback,main_figure});
                 src.WindowButtonDownFcn = @(src,envdata)edit_bottom(src,envdata,main_figure);
%                  set(enabled_obj,'Enable','on');
                 return;
         end

        [xinit,yinit]=check_xy();
        u=length(xinit)+1;
        update_bot(xinit,yinit);
        layer.Transceivers(idx_freq).setBottom(bot);
        curr_disp.Bot_changed_flag=1; 
        src.WindowButtonMotionFcn = @wbmcb_ext;
        set_alpha_map(main_figure);
        set_alpha_map(main_figure,'main_or_mini','mini');
        display_bottom(main_figure);
        if isvalid(hp)
            set(hp,'XData',xinit,'YData',yinit);
        else
           hp=plot(ah,xinit,yinit,'color',line_col,'linewidth',1,'Tag','bottom_temp'); 
        end
         
        
    end

    function [x_f, y_f]=check_xy()
        xinit(isnan(xinit))=[];
        yinit(isnan(yinit))=[];
        x_rem=xinit>xdata(end)|xinit<xdata(1);
        y_rem=yinit>ydata(end)|yinit<ydata(1);

        xinit(x_rem|y_rem)=[];
        yinit(x_rem|y_rem)=[];
        
        [x_f,IA,~] = unique(xinit);
        y_f=yinit(IA);
    end

    function wbucb(src,~)
        
        delete(hp);
        
       [x_f,y_f]=check_xy();
       update_bot(x_f,y_f);

        end_bottom_edit();
        
    end

    function update_bot(x_f,y_f)
        if length(x_f)>1
            for i=1:length(x_f)-1
                [~, idx_bot]=nanmin(abs(x_f(i)-xdata));
                [~, idx_bot_1]=nanmin(abs(x_f(i+1)-xdata));
                [~,idx_r]=nanmin(abs(y_f(i)-ydata));
                [~,idx_r1]=nanmin(abs(y_f(i+1)-ydata));
                
                idx_bot_tot=(idx_bot:idx_bot_1);
                
                bot.Sample_idx(idx_bot_tot)=round(linspace(idx_r,idx_r1,length(idx_bot_tot)));
            end
        elseif length(x_f)==1
            [~, idx_bot]=nanmin(abs(x_f-xdata));
            [~,idx_r]=nanmin(abs(y_f-ydata));
            bot.Sample_idx(idx_bot)=idx_r;
        end
    end

    function wbucb_alt(src,~)
        

        delete(hp);
        x_min=nanmin(xinit);
        x_max=nanmax(xinit);
        
        [~, idx_min]=nanmin(abs(x_min-xdata));
        [~, idx_max]=nanmin(abs(x_max-xdata));
        idx_pings=(idx_min:idx_max);
        bot.Sample_idx(idx_pings)=nan;
        end_bottom_edit();
        
        
    end


    function end_bottom_edit()
        src.WindowButtonMotionFcn = wbmcb_ori;
        src.WindowButtonUpFcn = wbucb_ori;
        layer.Transceivers(idx_freq).setBottom(bot);
        curr_disp.Bot_changed_flag=1; 
        setappdata(main_figure,'Curr_disp',curr_disp);
        setappdata(main_figure,'Layer',layer);
        reset_disp_info(main_figure);
        display_bottom(main_figure);
        set_alpha_map(main_figure);
        set_alpha_map(main_figure,'main_or_mini','mini');
        
    end
end
