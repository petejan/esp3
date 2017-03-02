function plot_profiles_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);


Bottom=trans.Bottom;

ax_main=axes_panel_comp.main_axes;


x_lim=double(get(ax_main,'xlim'));
y_lim=double(get(ax_main,'ylim'));


cp = ax_main.CurrentPoint;
x=cp(1,1);
y=cp(1,2);

x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));

y=nanmax(y,y_lim(1));
y=nanmin(y,y_lim(2));


xlab_str='Ping Number';
xdata=trans.get_transceiver_pings();

ydata=trans.get_transceiver_range();
[~,idx_ping]=nanmin(abs(xdata-x));
[~,idx_r]=nanmin(abs(ydata-y));
vert_val=trans.Data.get_subdatamat(1:length(ydata),idx_ping,'field',curr_disp.Fieldname);
horz_val=trans.Data.get_subdatamat(idx_r,1:length(xdata),'field',curr_disp.Fieldname);

switch lower(deblank(curr_disp.Fieldname))
    case{'alongangle','acrossangle'}
        ylab_str=sprintf('Angle(deg.)');
    case{'alongphi','acrossphi'}
        ylab_str=sprintf('Phase(deg.)');
    case 'power'
        ylab_str=sprintf('%s(dB)',curr_disp.Type);
        vert_val=pow2db_perso(vert_val);
        horz_val=pow2db_perso(horz_val);
    otherwise
        ylab_str=sprintf('%s(dB)',curr_disp.Type);
end


if ~isempty(Bottom.Sample_idx)
    if ~isnan(Bottom.Sample_idx(idx_ping))
        bot_val=ydata(Bottom.Sample_idx(idx_ping));
    else
        bot_val=nan;
    end
else
    bot_val=nan;
end
bot_x_val=[nanmin(vert_val(~(vert_val==-Inf))) nanmax(vert_val)];

v=new_echo_figure(main_figure,'Tag','profile_v');
axv=axes(v);
hold on;
title(sprintf('Vertical Profile for Ping: %.0f',idx_ping))
plot(axv,vert_val,ydata,'k');
hold on;
plot(axv,bot_x_val,[bot_val bot_val],'r');
grid on;
ylabel('Range(m)')
xlabel(ylab_str);
axis ij;
linkaxes([ax_main axv],'y');

h=new_echo_figure(main_figure,'Tag','profile_h');
axh=axes(h);
hold on;
title(sprintf('Horizontal Profile for sample: %.0f, Range: %.2fm',idx_r,y))
plot(axh,xdata,horz_val,'r');
grid on;
xlabel(xlab_str);
ylabel(ylab_str);
linkaxes([ax_main axh],'x');
switch curr_disp.Xaxes
    case 'Time'
        datetick(axh,'x','dd-mmm-yyyy HH:MM:SS')
end




end