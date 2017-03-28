%% poly_region_create.m
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
% * |main_figure|: TODO: write description and info on variable
% * |func|: TODO: write description and info on variable
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
% * 2017-03-24: header (Alex Schimel)
% * 2017-03-24: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function poly_region_create(main_figure,func)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

ah=axes_panel_comp.main_axes;


switch main_figure.SelectionType
    case 'extend'
        
    otherwise
%         curr_disp.CursorMode='Normal';
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

xinit=nan(1,1e4);
yinit=nan(1,1e4);
xinit(1) = cp(1,1);
yinit(1)=cp(1,2);
u=2;
xdata=layer.Transceivers(idx_freq).get_transceiver_pings();
ydata=layer.Transceivers(idx_freq).Data.get_range();

x_lim=get(ah,'xlim');
y_lim=get(ah,'ylim');

if xinit(1)<x_lim(1)||xinit(1)>xdata(end)||yinit(1)<y_lim(1)||yinit(1)>y_lim(end)
    return;
end
set(main_figure,'KeyPressFcn',@check_esc);

hp=line(ah,xinit,yinit,'color',col_line,'linewidth',1);
txt=text(ah,cp(1,1),cp(1,2),sprintf('%.2f m',cp(1,2)),'color',col_line);

% enabled_obj=findobj(main_figure,'Enable','on');
% set(enabled_obj,'Enable','off');
main_figure.WindowButtonMotionFcn = @wbmcb_ext;
main_figure.WindowButtonDownFcn = @wbdcb_ext;

   function wbmcb_ext(~,~)
       
        cp=ah.CurrentPoint;
        xinit(u)=cp(1,1);
        yinit(u)=cp(1,2);
        display_info_ButtonMotionFcn([],[],main_figure,1);
        
        if isvalid(hp)
            set(hp,'XData',xinit,'YData',yinit);
        else
            hp=plot(ah,xinit,yinit,'color',col_line,'linewidth',1,'Tag','reg_temp');
        end
        
        if isvalid(txt)
            set(txt,'position',[cp(1,1) cp(1,2) 0],'string',sprintf('%.2f m',cp(1,2)));
        else
            txt=text(ah,cp(1,1),cp(1,2),sprintf('%.2f m',cp(1,2)),'color',col_line);
        end
   end

    function wbdcb_ext(~,~)
        
        switch main_figure.SelectionType
            case {'open' 'alt'}

                wbucb(main_figure,[]);

                set(main_figure,'WindowButtonDownFcn',@create_region);
%                 set(enabled_obj,'Enable','on');
                return;
        end
        
        check_xy();
        u=length(xinit)+1;
        
        main_figure.WindowButtonMotionFcn = @wbmcb_ext;

        if isvalid(hp)
            set(hp,'XData',xinit,'YData',yinit);
        else
            hp=plot(ah,xinit,yinit,'color',col_line,'linewidth',1,'Tag','reg_temp');
        end
        
        
    end

    function check_xy()
        xinit(isnan(xinit))=[];
        yinit(isnan(yinit))=[];
        x_rem=xinit>xdata(end)|xinit<xdata(1);
        y_rem=yinit>ydata(end)|yinit<ydata(1);

        xinit(x_rem|y_rem)=[];
        yinit(x_rem|y_rem)=[];
        
%         [x_f,IA,~] = unique(xinit);
%         y_f=yinit(IA);
    end

    function wbucb(main_figure,~)
        
        main_figure.WindowButtonMotionFcn = '';
        main_figure.WindowButtonUpFcn = '';
        set(main_figure,'KeyPressFcn',{@keyboard_func,main_figure});
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
        delete(hp);
        if length(poly_pings)<=2
            return;
        end
        poly_pings=[poly_pings poly_pings(1)];
        poly_r=[poly_r poly_r(1)];
        reset_disp_info(main_figure);

        feval(func,main_figure,poly_r,poly_pings);

        
    end

    function check_esc(~,callbackdata)
        switch callbackdata.Key
            
            case {'escape'}
                xinit=[];
                yinit=[];
                wbucb(main_figure,[]);
                set(main_figure,'WindowButtonDownFcn',@create_region);
                return;
                
        end
    end
end
