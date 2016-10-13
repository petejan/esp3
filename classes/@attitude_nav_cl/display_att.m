function h_fig=display_att(obj)

if isempty(obj.Time)
    h_fig=[];
    return;
end


heading=obj.Heading;
pitch=obj.Pitch;
roll=obj.Roll;
heave=obj.Heave;
time=(obj.Time-obj.Time(1))*24*60*60;
u=0;
if ~isempty(roll)
    u=u+1;
    h_fig(u)=new_echo_figure([],'Name','Attitude','Tag','attitude');
    ax= axes('nextplot','add');
    yyaxis(ax,'left');
    ax.YAxis(1).Color = 'r';
    plot(ax,time,heave,'r');
    xlabel('Time(s)');
    ylabel('Heave (m)');
    
    yyaxis(ax,'right');
    plot(ax,time,pitch,'k');
    plot(ax,time,roll,'g');
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
    u=u+1;
    h_fig(u)=new_echo_figure([],'Name','Heading','Tag','attitude');
    axh=axes('nextplot','add');
    axh.YAxis.TickLabelFormat  = '%g^\\circ';
    plot(time,heading,'k');
    xlabel('Time(s)');
    ylabel('Heading');
    grid on;
    linkaxes([ axh],'x');
end

end