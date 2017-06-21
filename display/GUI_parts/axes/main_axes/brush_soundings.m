%% brush_soundings.m
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
% * 2017-06-21: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function brush_soundings(src,~,main_figure)

% main_figure=ancestor(src,'figure');
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;
mode='rectangular';
switch src.SelectionType
    case 'normal'
       set_bad=0;
    case {'alt','extend'}
       set_bad=1;
    case 'open'
        clear_lines(ah);
        u=findobj(ah,'Tag','BrushedLine','-or','Tag','BrushedArea');
        delete(u);
        return;
end

clear_lines(ah);
u=findobj(ah,'Tag','BrushedLine','-or','Tag','BrushedArea');
delete(u);


switch curr_disp.Cmap
    case 'esp2'
        col=[0 0 1];
    otherwise
        col=[1 0 0];
end


idx_freq=find_freq_idx(layer,curr_disp.Freq);

xdata=layer.Transceivers(idx_freq).get_transceiver_pings();
ydata=layer.Transceivers(idx_freq).get_transceiver_samples();
bottom_idx=layer.Transceivers(idx_freq).get_bottom_idx();

x_lim=get(ah,'xlim');
y_lim=get(ah,'ylim');
cp = ah.CurrentPoint;
xinit = cp(1,1);
yinit = cp(1,2);
if xinit<x_lim(1)||xinit>x_lim(end)||yinit<y_lim(1)||yinit>y_lim(end)
    return;
end
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


x_box=xinit;
y_box=yinit;


hp=line(x_box,y_box,'color',col,'linewidth',1,'parent',ah,'LineStyle','--','Tag','BrushedLine');
hp_p=plot(nan,nan,'Marker','*','color',col,'linewidth',1,'parent',ah,'LineStyle','none','Tag','BrushedLine');


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

        idx_brush=intersect(round(x_min:x_max),find((bottom_idx>=y_min)&bottom_idx<=y_max))

        set(hp_p,'XData',idx_brush,'YData',bottom_idx(idx_brush));
        
        set(hp,'XData',x_box,'YData',y_box);
        
        
    end

    function wbucb(src,~)
    replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2);
    replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',2);

        delete(hp);
        delete(hp_p);

        switch mode
            case 'horizontal'
                [idx_freq,~]=layer.find_freq_idx(curr_disp.Freq);
                x=layer.Transceivers(idx_freq).get_transceiver_pings();
                x_box=([x(1) x(end)  x(end) x(1) x(1)]);
            case 'vertical'
            otherwise
        end
        
        if length(x_box)<4||length(y_box)<4
            return;
        end
        hp_a=patch(ah,'XData',x_box(1:4),'YData',y_box(1:4),'FaceColor',col,'tag','BrushedArea','FaceAlpha',0.5,'EdgeColor',col);
        
        brush_off_soundings_callback([],[],hp_a,main_figure,set_bad);
        delete(hp_a);
        
        
    end

end