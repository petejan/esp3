function update_grid(main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);

xdata=get(axes_panel_comp.main_echo,'XData');
ydata=get(axes_panel_comp.main_echo,'YData');

[idx_r,idx_pings]=get_idx_r_n_pings(layer,curr_disp,axes_panel_comp.main_echo);

switch curr_disp.Xaxes
    case 'seconds'
        xdata_grid=layer.Transceivers(idx_freq).Time(idx_pings);
    case 'pings'
        xdata_grid=layer.Transceivers(idx_freq).get_transceiver_pings(idx_pings);
    case 'meters'
        xdata_grid=layer.Transceivers(idx_freq).GPSDataPing.Dist();
        if isempty(xdata_grid)
            disp('NO GPS Data');
            curr_disp.Xaxes='pings';
            xdata_grid=layer.Transceivers(idx_freq).get_transceiver_pings(idx_pings);
        else
            xdata_grid=xdata_grid(idx_pings);
        end
    otherwise
        xdata_grid=layer.Transceivers(idx_freq).get_transceiver_pings(idx_pings);      
end

ydata_grid=layer.Transceivers(idx_freq).get_transceiver_range(idx_r);

 
switch curr_disp.Xaxes
    case 'seconds'
        dx=curr_disp.Grid_x/(24*60*60);
    otherwise
        dx=curr_disp.Grid_x;
end

idx_xticks=find((diff(rem(xdata_grid,dx))<0))+1;
idx_yticks=find((diff(rem(ydata_grid,curr_disp.Grid_y))<0))+1;

set(axes_panel_comp.main_axes,'Xtick',xdata(idx_xticks),'Ytick',ydata(idx_yticks),'XAxisLocation','top','XGrid','on','YGrid','on','YDir','reverse');

set(axes_panel_comp.vaxes,'YTick',ydata(idx_yticks));
set(axes_panel_comp.haxes,'XTick',xdata(idx_xticks));

set(axes_panel_comp.vaxes,'box','on');
fmt=' %.0fm';
y_labels=cellfun(@(x) num2str(x,fmt),num2cell(ydata_grid(idx_yticks)),'UniformOutput',0);
set(axes_panel_comp.vaxes,'yticklabels',y_labels);

set(axes_panel_comp.haxes,'XTickLabelRotation',-90,'box','on');
str_start='  ';

switch lower(curr_disp.Xaxes)
    case 'seconds'
        h_fmt='  HH:MM:SS';
        x_labels=cellfun(@(x) datestr(x,h_fmt),num2cell(xdata_grid(idx_xticks)),'UniformOutput',0);
    case 'pings'
        fmt=[str_start '%.0f'];
        axes_panel_comp.haxes.XTickLabelMode='auto';
        x_labels=cellfun(@(x) num2str(x,fmt),num2cell(xdata_grid(idx_xticks)),'UniformOutput',0);
    case 'meters'
        axes_panel_comp.haxes.XTickLabelMode='auto';
        fmt=[str_start '%.0fm'];
       x_labels=cellfun(@(x) num2str(x,fmt),num2cell(xdata_grid(idx_xticks)),'UniformOutput',0);
    otherwise
        axes_panel_comp.haxes.XTickLabelMode='auto';
        fmt=[str_start '%.0f'];
       x_labels=cellfun(@(x) num2str(x,fmt),num2cell(xdata_grid(idx_xticks)),'UniformOutput',0);
end
set(axes_panel_comp.haxes,'xticklabels',x_labels);


end