function update_axis_panel(main_figure,new)
layer=getappdata(main_figure,'Layer');
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
    return;
end

[~,found]=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);

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

delete(axes_panel_comp.listeners);
clear_lines(axes_panel_comp.main_axes);

layer.display_layer(curr_disp.Freq,curr_disp.Fieldname,axes_panel_comp.main_axes,axes_panel_comp.main_echo,x,y,new);

if strcmpi(curr_disp.CursorMode,'Normal')  
    create_context_menu_main_echo(main_figure,axes_panel_comp.main_echo);
end

axes_panel_comp.listeners=addlistener(axes_panel_comp.main_axes,'YLim','PostSet',@(src,envdata)listenYLim(src,envdata,main_figure)); 

setappdata(main_figure,'Axes_panel',axes_panel_comp);
update_grid(main_figure);
end