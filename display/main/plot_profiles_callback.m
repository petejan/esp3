function plot_profiles_callback(src,~,main_figure)

axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');


ax_main=axes_panel_comp.main_axes;
axh=axes_panel_comp.haxes;
axv=axes_panel_comp.vaxes;

% xdata=get(axes_panel_comp.main_echo,'XData');
% ydata=get(axes_panel_comp.main_echo,'YData');

x_lim=double(get(ax_main,'xlim'));
y_lim=double(get(ax_main,'ylim'));
xdata=double(get(axes_panel_comp.main_echo,'XData'));
ydata=double(get(axes_panel_comp.main_echo,'YData'));
cdata=double(get(axes_panel_comp.main_echo,'CData'));

cp = ax_main.CurrentPoint;
x=cp(1,1);
y=cp(1,2);

x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));

y=nanmax(y,y_lim(1));
y=nanmin(y,y_lim(2));

switch curr_disp.Xaxes
    case 'Time'
        xlab_str='Time';
    case 'Distance'
        xlab_str='Distance (m)';
    case 'Number'
        xlab_str='Ping Number';      
end


    switch lower(deblank(curr_disp.Fieldname))
        case{'alongangle','acrossangle'}
            ylab_str=sprintf('Angle(deg.)');
        case{'alongphi','acrossphi'}
            ylab_str=sprintf('Phase(deg.)');
        otherwise
            ylab_str=sprintf('%s(dB)',curr_disp.Type);
    end

if ~isempty(cdata)
    [~,idx_ping]=nanmin(abs(xdata-x));
    [~,idx_r]=nanmin(abs(ydata-y));
    
    figure();
    axv=axes();
    hold on;
    title(sprintf('Vertical Profile for Ping: %.0f',idx_ping))
    plot(cdata(:,idx_ping),ydata,'k');
    grid on;
    ylabel('Range(m)')
    xlabel(ylab_str);
    set(axv,'YTick',get(axes_panel_comp.main_axes,'YTick'));
    axis ij;

    figure();
    axh=axes();
    hold on;
    title(sprintf('Horizontal Profile for sample: %.0f, Range: %.2fm',idx_r,y))
    plot(xdata,cdata(idx_r,:),'r');
    grid on;
    xlabel(xlab_str);
    ylabel(ylab_str);
    set(axh,'XTick',get(axes_panel_comp.main_axes,'XTick'));
   
end

update_xtick_labels([],[],axh,curr_disp.Xaxes);
update_ytick_labels([],[],axv);

end