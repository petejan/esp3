function update_display_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
display_tab_comp=getappdata(main_figure,'Display_tab');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);


Axes_type={'pings','seconds','meters'};

idx_axes=find(strcmp(curr_disp.Xaxes_current,Axes_type));

if isempty(idx_axes)
    idx_axes=1;
    curr_disp.Xaxes_current=Axes_type{1};
end

[idx_field,~]=trans_obj.Data.find_field_idx(curr_disp.Fieldname);
[dx,dy]=curr_disp.get_dx_dy();

set(display_tab_comp.grid_x,'String',num2str(dx,'%.0f'));
set(display_tab_comp.grid_y,'String',num2str(dy,'%.0f'));

set(display_tab_comp.tog_freq,'String',num2str(layer.Frequencies'),'Value',idx_freq);
set(display_tab_comp.tog_type,'String',trans_obj.Data.Type,'Value',idx_field);
set(display_tab_comp.tog_axes,'String',Axes_type,'Value',idx_axes);
set(display_tab_comp.caxis_up,'String',num2str(curr_disp.Cax(2),'%.0f'));
set(display_tab_comp.caxis_down,'String',num2str(curr_disp.Cax(1),'%.0f'));

%set(findall(display_tab_comp.display_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Display_tab',display_tab_comp);
end