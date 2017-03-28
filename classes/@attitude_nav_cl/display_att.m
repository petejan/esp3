function h_fig=display_att(obj,parenth)

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



heading=obj.Heading;
pitch=obj.Pitch;
roll=obj.Roll;
heave=obj.Heave;
yaw=obj.Yaw;
time=(obj.Time-obj.Time(1))*24*60*60;

h_fig=new_echo_figure(parenth,'Name','Attitude','Tag','attitude');
if ~isempty(roll)
    ax= axes(h_fig,'nextplot','add','OuterPosition',[0 0.5 1 0.5]);
    yyaxis(ax,'left');
    ax.YAxis(1).Color = 'r';
    plot(ax,time,heave,'r');
    xlabel('Time(s)');
    ylabel('Heave (m)');
    
    yyaxis(ax,'right');
    plot(ax,time,pitch,'k');
    plot(ax,time,roll,'color',[0 0.5 0]);
    ax.YAxis(2).Color = 'k';
    ax.YAxis(2).TickLabelFormat  = '%g^\\circ';
    legend('Heave','Pitch','Roll','Location','northeast')
    legend('boxoff')
    ylabel('Attitude');
    grid on; 
else
    ax=[];
end

if ~isempty(heading)
    heading(heading==-999)=nan;
        axh=axes(h_fig,'nextplot','add','OuterPosition',[0 0 0.5 0.5]);
        axh.YAxis.TickLabelFormat  = '%g^\\circ';
        plot(axh,time,heading,'k');
        xlabel('Time(s)');
        ylabel('Heading');
        grid on;

else
   axh=[]; 
end

if ~isempty(yaw)
        axy=axes(h_fig,'nextplot','add','OuterPosition',[0.5 0 0.5 0.5]);
        axy.YAxis.TickLabelFormat  = '%g^\\circ';
        plot(axy,time,yaw,'k');
        xlabel('Time(s)');
        ylabel('Yaw');
        grid on;
else
    axy=[];
end

linkaxes([ah ax axh axy],'x');

end