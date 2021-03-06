%% zoom_in_callback.m
%
% TODO
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |src|: TODO
% * |main_figure|: TODO
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: complete header and in-code commenting
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments (Alex Schimel)
% * 2017-03-21: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function zoom_in_callback(src,~,main_figure)

if check_axes_tab(main_figure)==0
    return;
end
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;

switch main_figure.SelectionType
    case 'normal'
        mode='rectangular';
    case 'alt'
        mode='horizontal';
    case 'open'
        mode='reset';
    otherwise
        return;
end
switch lower(curr_disp.Cmap)
    case 'esp2'
        col_line='w';
    otherwise
        col_line='k';
end



clear_lines(ah);

xdata=get(axes_panel_comp.main_echo,'XData');
ydata=get(axes_panel_comp.main_echo,'YData');
cp = ah.CurrentPoint;

trans=layer.get_trans(curr_disp);

xdata_tot=trans.get_transceiver_pings();       
ydata_tot=trans.get_transceiver_samples();


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
    case 'reset'      
        set(ah,'XLim',[xdata_tot(1) xdata_tot(end)],'YLim',[ydata_tot(1) ydata_tot(end)]);
        return;
end

if xinit<xdata(1)||xinit>xdata(end)||yinit<ydata(1)||yinit>ydata(end)
    return;
end

x_box=xinit;
y_box=yinit;


hp=line(x_box,y_box,'color',col_line,'linewidth',1,'parent',ah);

replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2,'interaction_fcn',@wbmcb);
replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',2,'interaction_fcn',@wbucb);

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
        
        
    end

    function wbucb(~,~)
        delete(hp);

        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2);
        replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',2);

        y_min=nanmin(y_box);
        y_max=nanmax(y_box);
        
        y_min=nanmax(y_min,ydata(1));
        y_max=nanmin(y_max,ydata(end));
        
        x_min=nanmin(x_box);
        x_min=nanmax(xdata(1),x_min);
        
        x_max=nanmax(x_box);
        x_max=nanmin(xdata(end),x_max);
        
        
        if x_max==x_min||y_max==y_min
            x_lim=get(ah,'XLim');
            y_lim=get(ah,'YLim');
            dx=abs(diff(x_lim));
            dy=diff(y_lim);
            
            x_lim(1)=x_lim(1)+dx/4;
            y_lim(1)=y_lim(1)+dy/4;
            x_lim(2)=x_lim(2)-dx/4;
            y_lim(2)=y_lim(2)-dy/4;
            
        else
            x_lim=[x_min x_max];
            y_lim=[y_min y_max];
        end
        
        set(ah,'XLim',x_lim,'YLim',y_lim);
        
        
    end

end