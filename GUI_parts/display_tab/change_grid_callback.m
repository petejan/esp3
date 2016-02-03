function change_grid_callback(src,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);


switch curr_disp.Xaxes
    case 'Distance'
        grid_x_unit='(m)';
    case 'Time'
        grid_x_unit='(s)';
    otherwise 
        grid_x_unit='';
end

set(display_tab_comp.grid_x_unit,'string',grid_x_unit);


val=str2double(get(src,'string'));
if val>0
    curr_disp.Grid_x=str2double(get(display_tab_comp.grid_x,'string'));
    curr_disp.Grid_y=str2double(get(display_tab_comp.grid_y,'string'));
else
    set(display_tab_comp.grid_x,'string',num2str(curr_disp.Grid_x,'%.0f'));
    set(display_tab_comp.grid_y,'string',num2str(curr_disp.Grid_y,'%.0f'));
    return;
end

xdata=get(axes_panel_comp.main_echo,'XData');
ydata=get(axes_panel_comp.main_echo,'YData');

[~,idx_pings]=get_idx_r_n_pings(layer,curr_disp,axes_panel_comp.main_echo);

switch curr_disp.Xaxes
    case 'Time'
        xdata_grid=layer.Transceivers(idx_freq).Data.Time(idx_pings);
    case 'Number'
        xdata_grid=layer.Transceivers(idx_freq).Data.Number(idx_pings);
    case 'Distance'
        xdata_grid=layer.Transceivers(idx_freq).GPSDataPing.Dist(idx_pings);
        if isempty(xdata)
            disp('NO GPS Data');
            curr_disp.Xaxes='Number';
            xdata_grid=layer.Transceivers(idx_freq).Data.Number(idx_pings);
        end
    otherwise
        xdata_grid=layer.Transceivers(idx_freq).Data.Number(idx_pings);      
end


switch curr_disp.Xaxes
    case 'Time'
        dx=curr_disp.Grid_x/(24*60*60);
    otherwise
        dx=curr_disp.Grid_x;
end

cax=layer.Transceivers(idx_freq).Data.get_caxis(curr_disp.Fieldname);

format_main_axes(axes_panel_comp.main_axes,cax,curr_disp.Xaxes,xdata_grid,ydata,xdata,ydata,dx,curr_disp.Grid_y);
xticks=get(axes_panel_comp.main_axes,'XTick');
yticks=get(axes_panel_comp.main_axes,'YTick');
xticks_label=get(axes_panel_comp.main_axes,'XtickLabel');
yticks_label=get(axes_panel_comp.main_axes,'YtickLabel');

set(axes_panel_comp.vaxes,'YTick',yticks);
set(axes_panel_comp.haxes,'XTick',xticks);
set(axes_panel_comp.vaxes,'YtickLabel',yticks_label);
set(axes_panel_comp.haxes,'XtickLabel',xticks_label,'XTickLabelRotation',90,'box','on');

display_info_ButtonMotionFcn([],[],main_figure,1)


end