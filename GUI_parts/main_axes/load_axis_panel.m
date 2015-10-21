function load_axis_panel(main_figure,new)

layer=getappdata(main_figure,'Layer');
display_tab_comp=getappdata(main_figure,'Display_tab');

axes_panel_comp=getappdata(main_figure,'Axes_panel');


curr_disp=getappdata(main_figure,'Curr_disp');

try
    x=double(get(axes_panel_comp.main_axes,'xlim'));
    y=double(get(axes_panel_comp.main_axes,'ylim'));
catch
    x=[0 0];
    y=[0 0];
end


[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);

if found==0
    idx_freq=1;
    curr_disp.Freq=layer.Frequencies(idx_freq);
end

set(display_tab_comp.tog_freq,'String',num2str(layer.Frequencies'),'Value',idx_freq);

[idx_field,found]=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);

if found==0
    [idx_field,~]=find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
    curr_disp.setField('sv');
end

set(display_tab_comp.tog_type,'String',layer.Transceivers(idx_freq).Data.Type,'Value',idx_field);

if isfield(axes_panel_comp,'axes_listener_xlim')
    delete(axes_panel_comp.axes_listener_xlim);
    delete(axes_panel_comp.axes_listener_ylim);
end

delete(allchild(axes_panel_comp.axes_panel));

axes_panel_comp.vaxes=axes('Parent',axes_panel_comp.axes_panel,'FontSize',10,'Fontweight','Bold','Units','normalized',...
    'Position',[0 0 0 0],...
    'XAxisLocation','Top',...
    'YAxisLocation','right',...
    'TickLength',[0 0],...
    'visible','on',...
    'box','on',...
    'XTickLabel',{[]},...
    'Xgrid','on',...
    'Ygrid','on',...
    'YDir','reverse');


axes_panel_comp.haxes=axes('Parent',axes_panel_comp.axes_panel,'FontSize',10,'Fontweight','Bold','Units','normalized',...
    'Position',[0 0 0 0],...
    'XAxisLocation','bottom',...
    'YAxisLocation','left',...
    'TickLength',[0 0],...
    'visible','on',...
    'box','on',...
    'YTickLabel',{[]},...
    'Xgrid','on',...
    'Ygrid','on');



axes_panel_comp.main_axes=axes('Parent',axes_panel_comp.axes_panel,'FontSize',10,'Units','normalized',...
    'Position',[0 0 1 1],...
    'Xlimmode','manual',...
    'Ylimmode','manual',...
    'XAxisLocation','bottom',...
    'TickDir','in',...
    'XTickLabel',{[]},...
    'YTickLabel',{[]},...
    'box','on',...
    'YDir','reverse');%'TickDir','in');

hold(axes_panel_comp.main_axes,'on')
axes_panel_comp.colorbar=colorbar(axes_panel_comp.main_axes);
axes_panel_comp.colorbar.Position=axes_panel_comp.colorbar.Position+[0 0.01 -axes_panel_comp.colorbar.Position(3)/2 -0.02];
colormap(axes_panel_comp.main_axes,jet);

axes_panel_comp.main_echo=layer.display_layer(curr_disp.Freq,curr_disp.Fieldname,axes_panel_comp.main_axes,curr_disp.Xaxes,x,y,curr_disp.Grid_x,curr_disp.Grid_y,new);

set(axes_panel_comp.vaxes,'YTick',get(axes_panel_comp.main_axes,'YTick'));
set(axes_panel_comp.haxes,'XTick',get(axes_panel_comp.main_axes,'XTick'));

context_menu=uicontextmenu;
axes_panel_comp.main_echo.UIContextMenu=context_menu;
uimenu(context_menu,'Label','Plot Profiles','Callback',{@plot_profiles_callback,main_figure});


% axes_panel_comp.axes_listener_xlim=addlistener(axes_panel_comp.main_axes,'XLim','PostSet',@(src,envdata)update_xtick_labels(src,envdata,axes_panel_comp.main_axes,curr_disp.Xaxes));
% axes_panel_comp.axes_listener_ylim=addlistener(axes_panel_comp.main_axes,'YLim','PostSet',@(src,envdata)update_ytick_labels(src,envdata,axes_panel_comp.main_axes));

set(display_tab_comp.caxis_up,'String',num2str(axes_panel_comp.main_axes.CLim(2),'%.0f'));
set(display_tab_comp.caxis_down,'String',num2str(axes_panel_comp.main_axes.CLim(1),'%.0f'));

idx_bottom=layer.Transceivers(idx_freq).Bottom.Sample_idx;
xdata=double(get(axes_panel_comp.main_echo,'XData'));
ydata=double(get(axes_panel_comp.main_echo,'YData'));

axes_panel_comp=display_bottom(xdata,ydata,idx_bottom,axes_panel_comp,curr_disp.DispBottom);
axes_panel_comp=display_tracks(xdata,layer.Transceivers(idx_freq).ST,layer.Transceivers(idx_freq).Tracks,axes_panel_comp,curr_disp.DispTracks);

hold(axes_panel_comp.haxes,'on');
hold(axes_panel_comp.vaxes,'on');

setappdata(main_figure,'Axes_panel',axes_panel_comp);
setappdata(main_figure,'Layer',layer);
set_axes_position(main_figure);


if ~isempty(layer.Transceivers(idx_freq).Regions)
    display_regions(main_figure)
end

if ~isempty(layer.Lines)
    display_lines(main_figure)
end

set_alpha_map(main_figure);
display_info_ButtonMotionFcn([],[],main_figure,1);
end