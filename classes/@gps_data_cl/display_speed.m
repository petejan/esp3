function h_fig=display_speed(obj)

if isempty(obj.Time)
    h_fig=[];
    return;
end

dist=obj.Dist;
time=(obj.Time(1:end)-obj.Time(1))*24*60*60;
if ~isempty(dist)
    speed=diff(dist/1852)./diff(time/3600);
    h_fig=new_echo_figure([],'Name','Speed','Tag','speed');
    plot(time(2:end),speed,'k');
    xlabel('Time(s)');
    ylabel('Speed (knot)');
    grid on;
else
    h_fig=[];
end

end