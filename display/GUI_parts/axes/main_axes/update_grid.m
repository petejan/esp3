function update_grid(main_figure)

layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,~]=layer.get_trans(curr_disp);
if isempty(trans_obj)
    return;
end
try
    xdata=get(axes_panel_comp.main_echo,'XData');
    ydata=get(axes_panel_comp.main_echo,'YData');
    
    [idx_r,idx_pings]=get_idx_r_n_pings(layer,curr_disp,axes_panel_comp.main_echo);
    
    curr_disp=init_grid_val(main_figure);
    [dx,dy]=curr_disp.get_dx_dy();

    switch curr_disp.Xaxes_current
        case 'seconds'
            xdata_grid=trans_obj.Time(idx_pings);
            dx=dx/(24*60*60);
        case 'pings'
            xdata_grid=trans_obj.get_transceiver_pings(idx_pings);
        case 'meters'
            xdata_grid=trans_obj.GPSDataPing.Dist();
            if  ~any(~isnan(trans_obj.GPSDataPing.Lat))
                disp('No GPS Data');
                curr_disp.Xaxes_current='pings';
                curr_disp=init_grid_val(main_figure);
                [dx,dy]=curr_disp.get_dx_dy();
                xdata_grid=trans_obj.get_transceiver_pings(idx_pings);
            else
                xdata_grid=xdata_grid(idx_pings);
            end
        otherwise
            xdata_grid=trans_obj.get_transceiver_pings(idx_pings);
    end
    
     
    ydata_grid=trans_obj.get_transceiver_range(idx_r);
    
    dxmin=2;
    dymin=2;
    
    dx_min=dx/dxmin;
    dy_min=dy/dymin;
    
    idx_minor_xticks=find((diff(rem(xdata_grid,dx_min))<0))+1;
    
    if isempty(idx_minor_xticks)
        idx_minor_xticks=find((diff(rem(xdata_grid,dx))<0))+1;
        dxmin=1;
    end
    
    idx_minor_yticks=find((diff(rem(ydata_grid,dy_min))<0))+1;
    
    if isempty(idx_minor_yticks)
        idx_minor_yticks=find((diff(rem(ydata_grid,dy))<0))+1;
        dymin=1;
    end

    idx_xticks=idx_minor_xticks(dxmin:dxmin:end);
    idx_yticks=idx_minor_yticks(dymin:dymin:end);
    
    idx_minor_xticks=setdiff(idx_minor_xticks,idx_xticks);
    idx_minor_yticks=setdiff(idx_minor_yticks,idx_yticks);
    
    axes_panel_comp.main_axes.XTick=xdata(idx_xticks);
    axes_panel_comp.main_axes.YTick=ydata(idx_yticks);
    
    axes_panel_comp.main_axes.XAxis.MinorTickValues=xdata(idx_minor_xticks);
    axes_panel_comp.main_axes.YAxis.MinorTickValues=ydata(idx_minor_yticks);
    
    set(axes_panel_comp.main_axes,'Xgrid','on','Ygrid','on','XAxisLocation','top'); 
    set(axes_panel_comp.vaxes,'box','on');
    
    fmt=' %.0fm';
    yl=num2cell(floor(ydata_grid(idx_yticks)/dy)*dy);
    y_labels=cellfun(@(x) num2str(x,fmt),yl,'UniformOutput',0);
    set(axes_panel_comp.vaxes,'yticklabels',y_labels);
    
    set(axes_panel_comp.haxes,'XTickLabelRotation',-90,'box','on');
    str_start=' ';
    xl=num2cell(floor(xdata_grid(idx_xticks)/dx)*dx);
    switch lower(curr_disp.Xaxes_current)
        case 'seconds'
            h_fmt='HH:MM:SS';
            x_labels=cellfun(@(x) datestr(x,h_fmt),xl,'UniformOutput',0);
        case 'pings'
            fmt=[str_start '%.0f'];
            axes_panel_comp.haxes.XTickLabelMode='auto';
            x_labels=cellfun(@(x) num2str(x,fmt),xl,'UniformOutput',0);
        case 'meters'
            axes_panel_comp.haxes.XTickLabelMode='auto';
            fmt=[str_start '%.0fm'];
            x_labels=cellfun(@(x) num2str(x,fmt),xl,'UniformOutput',0);
        otherwise
            axes_panel_comp.haxes.XTickLabelMode='auto';
            fmt=[str_start '%.0f'];             
            x_labels=cellfun(@(x) num2str(x,fmt),xl,'UniformOutput',0);
    end
    set(axes_panel_comp.haxes,'xticklabels',x_labels);
catch err
    if ~isdeployed
        disp(err.message);
    end
    warning('Error while updating grid..');
end

end