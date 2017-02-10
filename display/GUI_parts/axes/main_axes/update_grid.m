function update_grid(main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);

xdata=get(axes_panel_comp.main_echo,'XData');
ydata=get(axes_panel_comp.main_echo,'YData');

[idx_r,idx_pings]=get_idx_r_n_pings(layer,curr_disp,axes_panel_comp.main_echo);

switch curr_disp.Xaxes
    case 'Time'
        xdata_grid=layer.Transceivers(idx_freq).Data.Time(idx_pings);
    case 'Number'
        xdata_grid=layer.Transceivers(idx_freq).Data.get_numbers(idx_pings);
    case 'Distance'
        xdata_grid=layer.Transceivers(idx_freq).GPSDataPing.Dist(idx_pings);
        if isempty(xdata)
            disp('NO GPS Data');
            curr_disp.Xaxes='Number';
            xdata_grid=layer.Transceivers(idx_freq).Data.get_numbers(idx_pings);
        end
    otherwise
        xdata_grid=layer.Transceivers(idx_freq).Data.get_numbers(idx_pings);      
end

ydata_grid=layer.Transceivers(idx_freq).get_transceiver_range(idx_r);
 
switch curr_disp.Xaxes
    case 'Time'
        dx=curr_disp.Grid_x/(24*60*60);
    otherwise
        dx=curr_disp.Grid_x;
end

idx_xticks=find((diff(rem(xdata_grid,dx))<0))+1;
idx_yticks=find((diff(rem(ydata_grid,curr_disp.Grid_y))<0))+1;

set(axes_panel_comp.main_axes,'Xtick',xdata(idx_xticks),'Ytick',ydata(idx_yticks),'XAxisLocation','top','XGrid','on','YGrid','on','YDir','reverse');

set(axes_panel_comp.vaxes,'YTick',ydata(idx_yticks));
set(axes_panel_comp.haxes,'XTick',xdata(idx_xticks));
axes_panel_comp.vaxes.YAxis.TickLabelFormat = '  %.0f m';
set(axes_panel_comp.vaxes,'box','on');
set(axes_panel_comp.haxes,'XTickLabelRotation',-90,'box','on');
str_start='  ';

switch lower(curr_disp.Xaxes)
    case 'time'
        h_fmt='  HH:MM:SS';
        labels=cellfun(@(x) datestr(x,h_fmt),num2cell(xdata_grid(idx_xticks)),'UniformOutput',0);
    case 'number'
        fmt=[str_start '%.0f'];
        axes_panel_comp.haxes.XTickLabelMode='auto';
        labels=cellfun(@(x) num2str(x,fmt),num2cell(xdata_grid(idx_xticks)),'UniformOutput',0);
    case 'distance'
        axes_panel_comp.haxes.XTickLabelMode='auto';
        fmt=[str_start '%.0f m'];
       labels=cellfun(@(x) num2str(x,fmt),num2cell(xdata_grid(idx_xticks)),'UniformOutput',0);
    otherwise
        axes_panel_comp.haxes.XTickLabelMode='auto';
        fmt=[str_start '%.0f'];
       labels=cellfun(@(x) num2str(x,fmt),num2cell(xdata_grid(idx_xticks)),'UniformOutput',0);
end
set(axes_panel_comp.haxes,'xticklabels',labels);

order_axes(main_figure);

end