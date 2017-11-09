function update_grid(main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,~]=layer.get_trans(curr_disp);
if isempty(trans_obj)
    return;
end
xdata=get(axes_panel_comp.main_echo,'XData');
ydata=get(axes_panel_comp.main_echo,'YData');

[idx_r,idx_pings]=get_idx_r_n_pings(layer,curr_disp,axes_panel_comp.main_echo);

switch curr_disp.Xaxes
    case 'seconds'
        xdata_grid=trans_obj.Time(idx_pings);
    case 'pings'
        xdata_grid=trans_obj.get_transceiver_pings(idx_pings);
    case 'meters'
        xdata_grid=trans_obj.GPSDataPing.Dist();
        if isempty(xdata_grid)
            disp('NO GPS Data');
            curr_disp.Xaxes='pings';
            xdata_grid=trans_obj.get_transceiver_pings(idx_pings);
        else
            xdata_grid=xdata_grid(idx_pings);
        end
    otherwise
        xdata_grid=trans_obj.get_transceiver_pings(idx_pings);      
end

ydata_grid=trans_obj.get_transceiver_range(idx_r);

 
switch curr_disp.Xaxes
    case 'seconds'
        dx=curr_disp.Grid_x/(24*60*60);
    otherwise
        dx=curr_disp.Grid_x;
end

% idx_xticks=find((diff(rem(xdata_grid,dx))<0))+1;
% idx_yticks=find((diff(rem(ydata_grid,curr_disp.Grid_y))<0))+1;

%set(axes_panel_comp.main_axes,'Xtick',xdata(idx_xticks),'Ytick',ydata(idx_yticks),'XAxisLocation','top','XGrid','on','YGrid','on');

dxmin=2;
dymin=2 ;
dx_min=dx/dxmin;
dy_min=curr_disp.Grid_y/dymin;

idx_minor_xticks=find((diff(rem(xdata_grid,dx_min))<0))+1;
idx_minor_yticks=find((diff(rem(ydata_grid,dy_min))<0))+1;
% 
idx_xticks=idx_minor_xticks(dxmin:dxmin:end);
idx_yticks=idx_minor_yticks(dymin:dymin:end);
% 
% idx_minor_xticks=setdiff(idx_minor_xticks,idx_xticks);
% idx_minor_yticks=setdiff(idx_minor_yticks,idx_yticks);
%
axes_panel_comp.main_axes.XTick=xdata(idx_xticks);
axes_panel_comp.main_axes.YTick=ydata(idx_yticks);
 
axes_panel_comp.main_axes.XAxis.MinorTickValues=xdata(idx_minor_xticks);
axes_panel_comp.main_axes.YAxis.MinorTickValues=ydata(idx_minor_yticks);

set(axes_panel_comp.main_axes,'Xgrid','on','Ygrid','on','XAxisLocation','top');

set(axes_panel_comp.vaxes,'YTick',ydata(idx_yticks));
set(axes_panel_comp.haxes,'XTick',xdata(idx_xticks));

set(axes_panel_comp.vaxes,'box','on');
fmt=' %.0fm';
y_labels=cellfun(@(x) num2str(x,fmt),num2cell(ydata_grid(idx_yticks)),'UniformOutput',0);
set(axes_panel_comp.vaxes,'yticklabels',y_labels);

set(axes_panel_comp.haxes,'XTickLabelRotation',-90,'box','on');
str_start=' ';

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