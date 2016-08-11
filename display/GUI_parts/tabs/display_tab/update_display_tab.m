function update_display_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
display_tab_comp=getappdata(main_figure,'Display_tab');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);

if isempty(layer.Transceivers(idx_freq).GPSDataPing)
    Axes_type={'Number','Time'};
else
    if ~isempty(layer.Transceivers(idx_freq).GPSDataPing.Dist)
        Axes_type={'Number','Time','Distance'};
    else
        Axes_type={'Number','Time'};
    end
end
idx_axes=find(strcmp(curr_disp.Xaxes,Axes_type));
[idx_field,~]=layer.Transceivers(idx_freq).Data.find_field_idx(curr_disp.Fieldname);


set(display_tab_comp.grid_x,'String',num2str(curr_disp.Grid_x,'%.0f'));
set(display_tab_comp.grid_y,'String',num2str(curr_disp.Grid_y,'%.0f'));

switch curr_disp.Xaxes
    case 'Number'
        str_ax='';
    case 'Time'
        str_ax='sec';
    case 'Distance'
        str_ax='m';
    
end

set(display_tab_comp.grid_x_unit,'string',str_ax);
set(display_tab_comp.tog_freq,'String',num2str(layer.Frequencies'),'Value',idx_freq);
set(display_tab_comp.tog_type,'String',layer.Transceivers(idx_freq).Data.Type,'Value',idx_field);
set(display_tab_comp.tog_axes,'String',Axes_type,'Value',idx_axes);
set(display_tab_comp.caxis_up,'String',num2str(curr_disp.Cax(2),'%.0f'));
set(display_tab_comp.caxis_down,'String',num2str(curr_disp.Cax(1),'%.0f'));

set(findall(display_tab_comp.display_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Display_tab',display_tab_comp);
end