function plot_profiles_callback(src,~,main_figure)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);


Bottom=trans.Bottom;

ax_main=ax_main;


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
    if ~isnan(Bottom.Sample_idx(idx_ping))
        bot_val=ydata(Bottom.Sample_idx(idx_ping));
    else
        bot_val=nan;
    end
    vert_val=cdata(:,idx_ping);
    bot_x_val=[nanmin(vert_val(~(vert_val==-Inf))) nanmax(vert_val)];
    horz_val=cdata(idx_r,:);
    
    figure();
    axv=axes();
    hold on;
    title(sprintf('Vertical Profile for Ping: %.0f',idx_ping))
    plot(vert_val,ydata,'k');
    hold on;
    plot(bot_x_val,[bot_val bot_val],'r');
    grid on;
    ylabel('Range(m)')
    xlabel(ylab_str);
    set(axv,'YTick',get(ax_main,'YTick'));
    set(axv,'YTicklabel',get(ax_main,'YTicklabel'));
    axis ij;

    figure();
    axh=axes();
    hold on;
    title(sprintf('Horizontal Profile for sample: %.0f, Range: %.2fm',idx_r,y))
    plot(xdata,horz_val,'r');
    grid on;
    xlabel(xlab_str);
    ylabel(ylab_str);
    set(axh,'XTick',get(ax_main,'XTick'));
    set(axh,'XTicklabel',get(ax_main,'XTicklabel'));
   
end


end