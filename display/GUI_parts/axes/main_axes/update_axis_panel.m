function update_axis_panel(main_figure,new)
layer=getappdata(main_figure,'Layer');
display_tab_comp=getappdata(main_figure,'Display_tab');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');

if new==0
    try
        x=double(get(axes_panel_comp.main_axes,'xlim'));
        y=double(get(axes_panel_comp.main_axes,'ylim'));
    catch
        x=[0 0];
        y=[0 0];
    end
else
    x=[0 0];
    y=[0 0];
end

[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);

if found==0
    idx_freq=1;
    curr_disp.Freq=layer.Frequencies(idx_freq);
    setappdata(main_figure,'Curr_disp',curr_disp);
    return;
end

set(display_tab_comp.tog_freq,'String',num2str(layer.Frequencies'),'Value',idx_freq);

[idx_field,found]=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);

if found==0
    [~,found]=find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
    if found==0
        field=layer.Transceivers(idx_freq).Data.Fieldname{1};
    else
        field='sv';
    end
    curr_disp.setField(field);
    setappdata(main_figure,'Curr_disp',curr_disp);
    return;
end
trans=layer.Transceivers(idx_freq);
Number=trans.Data.get_numbers();
Range=trans.Data.get_range();

set(display_tab_comp.tog_type,'String',trans.Data.Type,'Value',idx_field);
delete(axes_panel_comp.listeners);

clear_lines(axes_panel_comp.main_axes);
axes_panel_comp.colorbar.Position=axes_panel_comp.colorbar.Position+[0 0.01 -axes_panel_comp.colorbar.Position(3)/2 -0.02];

layer.display_layer(curr_disp.Freq,curr_disp.Fieldname,axes_panel_comp.main_axes,axes_panel_comp.main_echo,curr_disp.Xaxes,x,y,curr_disp.Grid_x,curr_disp.Grid_y,new);

axes_panel_comp.listeners=addlistener(axes_panel_comp.main_axes,'YLim','PostSet',@(src,envdata)listenYLim(src,envdata,main_figure)); 

switch lower(curr_disp.Cmap)
    case 'esp2'
        col='y'; % ESP2's colormap is 'black background' so the bottom line is drawn in yellow
        col_lab=[0.8 0.8 0.8];
        col_grid=[1 1 1];
    case 'ek500'
        col='g'; % Simrad sounders use a green bottom line
        col_lab='k';
        col_grid=[0 0 0];
    otherwise
        col='k';
        col_lab='k';
        col_grid=[0 0 0];
end
axes_panel_comp.main_axes.GridColor=col_grid;
xticks=get(axes_panel_comp.main_axes,'XTick');
yticks=get(axes_panel_comp.main_axes,'YTick');
xticks_label=get(axes_panel_comp.main_axes,'XtickLabel');
yticks_label=get(axes_panel_comp.main_axes,'YtickLabel');

set(axes_panel_comp.vaxes,'YTick',yticks,'YColor',col_lab);
set(axes_panel_comp.haxes,'XTick',xticks,'XColor',col_lab);

set(axes_panel_comp.vaxes,'YtickLabel',yticks_label);
set(axes_panel_comp.haxes,'XtickLabel',xticks_label,'XTickLabelRotation',90,'box','on');

if strcmpi(curr_disp.CursorMode,'Normal')  
    create_context_menu_main_echo(main_figure,axes_panel_comp.main_echo);
end

set(display_tab_comp.caxis_up,'String',num2str(axes_panel_comp.main_axes.CLim(2),'%.0f'));
set(display_tab_comp.caxis_down,'String',num2str(axes_panel_comp.main_axes.CLim(1),'%.0f'));

idx_bottom=trans.Bottom.Sample_idx;

xdata_real=Number;
display_bottom(xdata_real,Range,idx_bottom,axes_panel_comp,curr_disp.DispBottom,col);
if strcmpi(curr_disp.CursorMode,'Normal')
    create_context_menu_bottom(main_figure,axes_panel_comp.bottom_plot);
end
axes_panel_comp=display_tracks(xdata_real,trans.ST,trans.Tracks,axes_panel_comp,curr_disp.DispTracks);


setappdata(main_figure,'Axes_panel',axes_panel_comp);
setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Curr_disp',curr_disp);
set_axes_position(main_figure);
display_file_lines(main_figure);
reverse_y_axis(main_figure);

display_regions(main_figure)
display_lines(main_figure)
set_alpha_map(main_figure);
display_info_ButtonMotionFcn([],[],main_figure,1);
order_axes(main_figure);
end