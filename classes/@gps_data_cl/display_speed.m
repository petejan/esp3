function h_fig=display_speed(obj,parenth)

if isempty(obj.Time)
    h_fig=[];
    return;
end

if ~isempty(parenth)
    axes_panel_comp=getappdata(parenth,'Axes_panel');
    if~isempty(axes_panel_comp)
        ah=axes_panel_comp.main_axes;
    else
        ah=[];
    end
else
    ah=[];
end


dist=obj.Dist;
time=(obj.Time(1:end)-obj.Time(1))*24*60*60;
if ~isempty(dist)
    speed=diff(dist/1852)./diff(time/3600);
    h_fig=new_echo_figure([],'Name','Speed','Tag','speed');
    ax= axes(h_fig,'nextplot','add','OuterPosition',[0 0 1 1]);
    plot(ax,time(2:end),speed,'k');
    xlabel('Time(s)');
    ylabel('Speed (knot)');
    grid on;
else
    h_fig=[];
end

linkaxes([ah ax],'x');

end