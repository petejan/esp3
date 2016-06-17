

function load_display_tab(main_figure,option_tab_panel)

if isappdata(main_figure,'Display_tab')
    display_tab_comp=getappdata(main_figure,'Display_tab');
    delete(display_tab_comp.display_tab);
    rmappdata(main_figure,'Display_tab');
end

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
if isempty(layer.Transceivers(idx_freq).Data.SubData)
    return;
end

[idx_field,~]=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);

display_tab_comp.display_tab=uitab(option_tab_panel,'Title','Display Option');
uicontrol(display_tab_comp.display_tab,'Style','Text','String','Frequency','units','normalized','Position',[0 0.8 0.2 0.1]);
display_tab_comp.tog_freq=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String',num2str(layer.Frequencies'),'Value',idx_freq,'units','normalized','Position', [0.2 0.8 0.12 0.1],'Callback',{@choose_freq,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Data','units','normalized','Position',[0 0.6 0.2 0.1]);
display_tab_comp.tog_type=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String',layer.Transceivers(idx_freq).Data.Type,'Value',idx_field,'units','normalized','Position', [0.2 0.6 0.12 0.1],'Callback',{@choose_field,main_figure});

if isempty(layer.Transceivers(idx_freq).GPSDataPing)
        Axes_type={'Number','Time'};
else
    if ~isempty(layer.Transceivers(idx_freq).GPSDataPing.Dist)
        Axes_type={'Number','Time','Distance'};
    else
         Axes_type={'Number','Time'};
    end
end
idx_axes=find(strcmp(curr_disp.Xaxes,Axes_type),1);

if isempty(idx_axes)
    idx_axes=1;
    curr_disp.Xaxes=Axes_type{idx_axes};
end

switch curr_disp.Xaxes
    case 'Distance'
        grid_x_unit='(m)';
    case 'Time'
        grid_x_unit='(s)';
    otherwise 
        grid_x_unit='';
end


uicontrol(display_tab_comp.display_tab,'Style','Text','String','X Axes:','units','normalized','Position',[0.35 0.8 0.1 0.1]);
display_tab_comp.tog_axes=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String',Axes_type,'Value',idx_axes,'units','normalized','Position', [0.45 0.8 0.2 0.1],'Callback',{@choose_Xaxes,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Grid:','units','normalized','Position',[0.35 0.6 0.05 0.1]);
display_tab_comp.grid_x=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.4 0.6 0.05 0.1],'string',num2str(curr_disp.Grid_x,'%.0f'));
display_tab_comp.grid_x_unit=uicontrol(display_tab_comp.display_tab,'Style','Text','unit','normalized','position',[0.45 0.6 0.04 0.1],'string',grid_x_unit);
uicontrol(display_tab_comp.display_tab,'Style','Text','String','X','units','normalized','Position',[0.49 0.6 0.02 0.1]);
display_tab_comp.grid_y=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.51 0.6 0.05 0.1],'string',num2str(curr_disp.Grid_y,'%.0f'));
display_tab_comp.grid_y_unit=uicontrol(display_tab_comp.display_tab,'Style','Text','unit','normalized','position',[0.56 0.6 0.04 0.1],'string','(m)');
set([display_tab_comp.grid_x display_tab_comp.grid_y],'callback',{@change_grid_callback,main_figure})



cax=layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay;
if isempty(cax)
    cax=[0 1];
end

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Disp Max (dB)','units','normalized','Position',[0.7 0.8 0.15 0.1]);
uicontrol(display_tab_comp.display_tab,'Style','Text','String','Disp Min (dB)','units','normalized','Position',[0.7 0.6 0.15 0.1]);

display_tab_comp.caxis_up=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.85 0.8 0.05 0.1],'string',cax(2));
display_tab_comp.caxis_down=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.85 0.6 0.05 0.1],'string',cax(1));
set([display_tab_comp.caxis_up display_tab_comp.caxis_down],'callback',{@set_caxis,main_figure});



display_tab_comp.mini_ax=axes('Parent',display_tab_comp.display_tab,'Units','normalized',...
    'Position',[0.05 0.1 0.75 0.45]);


uicontrol(display_tab_comp.display_tab,'Style','pushbutton','String','Disp Att.','units','normalized','pos',[0.85 0.25 0.1 0.15],'callback',{@display_attitude,main_figure});
uicontrol(display_tab_comp.display_tab,'Style','pushbutton','String','Disp Nav.','units','normalized','pos',[0.85 0.1 0.1 0.15],'callback',{@display_navigation_callback,main_figure});

setappdata(main_figure,'Display_tab',display_tab_comp);

end





function display_attitude(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
hfigs=getappdata(main_figure,'ExternalFigures');

if isempty(layer.AttitudeNav)
    warning('No attitude');
    return;
end

new_figs=layer.AttitudeNav.display_att();

hfigs=[hfigs new_figs];
setappdata(main_figure,'ExternalFigures',hfigs);

end

