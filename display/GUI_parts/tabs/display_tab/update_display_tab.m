function update_display_tab(main_figure)

layer_obj=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
display_tab_comp=getappdata(main_figure,'Display_tab');

[trans_obj,idx_freq]=layer_obj.get_trans(curr_disp);


if isempty(layer_obj.GPSData.Lat)
    Axes_type= {'pings','seconds'};
else
    Axes_type= {'meters','pings','seconds'};
end


idx_axes=find(strcmp(curr_disp.Xaxes_current,Axes_type));

if isempty(idx_axes)
    idx_axes=1;
    curr_disp.Xaxes_current=Axes_type{1};
end

[idx_field,~]=trans_obj.Data.find_field_idx(curr_disp.Fieldname);
curr_disp=init_grid_val(main_figure);
[dx,dy]=curr_disp.get_dx_dy();

set(display_tab_comp.grid_x,'String',int2str(dx));
set(display_tab_comp.grid_y,'String',int2str(dy));

set(display_tab_comp.tog_freq,'String',num2str(layer_obj.Frequencies'/1e3,'%.0f kHz'),'Value',idx_freq);
set(display_tab_comp.tog_type,'String',trans_obj.Data.Type,'Value',idx_field);
set(display_tab_comp.tog_axes,'String',Axes_type,'Value',idx_axes);
set(display_tab_comp.caxis_up,'String',int2str(curr_disp.Cax(2)));
set(display_tab_comp.caxis_down,'String',int2str(curr_disp.Cax(1)));

%set(findall(display_tab_comp.display_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Display_tab',display_tab_comp);
end