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
    h_fig(u)=figure('Name','Attitude','NumberTitle','off','tag','attitude');
    ax(1)= axes();
    axes(ax(1));
    hold on;
    plot(time,heave,'r');
    ax(1).XColor = 'r';
    ax(1).YColor = 'r';
    ax1_pos = ax(1).Position; % position of first axes
    xlabel('Time');
    ylabel('Heave (m)');
    legend('Heave','Location','northwest')
    legend('boxoff')
    
    ax(2)= axes();
    axes(ax(2));
    plot(time,pitch,'k');
    hold on;
    plot(time,roll,'g');
    legend('Pitch','Roll','Location','northeast')
    legend('boxoff')
    ylabel('Attitude (deg)');
    set(ax(2),'Position',ax1_pos,...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none')
    grid on;
    linkaxes(ax,'x');
end
if ~isempty(heading)
    u=u+1;
    h_fig(u)=figure('Name','Heading','NumberTitle','off','tag','attitude');
    ax(3)=axes();
    plot(time,heading,'k');
    xlabel('Time');
    ylabel('Heading (deg)');
    grid on;
    linkaxes(ax,'x');
end

end