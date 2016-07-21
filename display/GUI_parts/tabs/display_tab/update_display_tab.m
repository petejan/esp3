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

idx_freq=find_freq_idx(layer,curr_disp.Freq);
[idx_field,found]=layer.Transceivers(idx_freq).Data.find_field_idx(curr_disp.Fieldname);

if found==0
    [idx_field,~]=layer.Transceivers(idx_freq).Data.find_field_idx('sv');
    curr_disp.setField(layer.Transceivers(idx_freq).Data.Fieldname{(idx_field)});
end

set(display_tab_comp.tog_type,'String',layer.Transceivers(idx_freq).Data.Type,'Value',idx_field);
set(display_tab_comp.tog_axes,'String',Axes_type);
set(findall(display_tab_comp.display_tab, '-property', 'Enable'), 'Enable', 'on');
setappdata(main_figure,'Curr_disp',curr_disp);

end