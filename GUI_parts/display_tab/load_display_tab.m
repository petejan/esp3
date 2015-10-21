

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
display_tab_comp.tog_freq=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String',num2str(layer.Frequencies'),'Value',idx_freq,'units','normalized','Position', [0.2 0.8 0.2 0.1],'Callback',{@choose_freq,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Data','units','normalized','Position',[0 0.6 0.2 0.1]);
display_tab_comp.tog_type=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String',layer.Transceivers(idx_freq).Data.Type,'Value',idx_field,'units','normalized','Position', [0.2 0.6 0.2 0.1],'Callback',{@choose_field,main_figure});

if isempty(layer.Transceivers(idx_freq).GPSDataPing)
    Axes_type={'Number','Time'};
else
    Axes_type={'Number','Time','Distance'};
end
idx_axes=find(strcmp(curr_disp.Xaxes,Axes_type),1);
if isempty(idx_axes)
    idx_axes=1;
    curr_disp.Xaxes=Axes_type(idx_axes);
end

uicontrol(display_tab_comp.display_tab,'Style','Text','String','X Axes','units','normalized','Position',[0.5 0.8 0.2 0.1]);
display_tab_comp.tog_axes=uicontrol(display_tab_comp.display_tab,'Style','popupmenu','String',Axes_type,'Value',idx_axes,'units','normalized','Position', [0.7 0.8 0.2 0.1],'Callback',{@choose_Xaxes,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','Text','String','X Grid','units','normalized','Position',[0.5 0.6 0.1 0.1]);
uicontrol(display_tab_comp.display_tab,'Style','Text','String','Y Grid','units','normalized','Position',[0.75 0.6 0.1 0.1]);
display_tab_comp.grid_x=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.6 0.6 0.1 0.1],'string',curr_disp.Grid_x);
display_tab_comp.grid_y=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.85 0.6 0.1 0.1],'string',curr_disp.Grid_y);
set([display_tab_comp.grid_x display_tab_comp.grid_y],'callback',{@change_grid_callback,main_figure})

cax=layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay;
if isempty(cax)
    cax=[0 1];
end

uicontrol(display_tab_comp.display_tab,'Style','Text','String','Disp Max (dB)','units','normalized','Position',[0 0.3 0.2 0.1]);
uicontrol(display_tab_comp.display_tab,'Style','Text','String','Disp Min (dB)','units','normalized','Position',[0 0.1 0.2 0.1]);

display_tab_comp.caxis_up=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.2 0.3 0.05 0.1],'string',cax(2));
display_tab_comp.caxis_down=uicontrol(display_tab_comp.display_tab,'Style','edit','unit','normalized','position',[0.2 0.1 0.05 0.1],'string',cax(1));
set([display_tab_comp.caxis_up display_tab_comp.caxis_down],'callback',{@set_caxis,main_figure});

% addlistener(curr_disp,{'Cax','DispBottom','DispReg','Freq'},'PostSet',@(src,envdata)listenChangeEcho(src,envdata,main_figure));
% addlistener(curr_disp,{},'PostSet',@(src,envdata)listenChangeFreq(src,envdata,main_figure));


display_tab_comp.disp_bottom=uicontrol(display_tab_comp.display_tab,'Style','checkbox','Value',1,'String','Display bottom','units','normalized','Position',[0.3 0.4 0.25 0.1]);
display_tab_comp.disp_bad_trans=uicontrol(display_tab_comp.display_tab,'Style','checkbox','Value',1,'String','Display Bad transmits','units','normalized','Position',[0.3 0.3 0.25 0.1]);
display_tab_comp.disp_reg=uicontrol(display_tab_comp.display_tab,'Style','checkbox','Value',1,'String','Display Regions','units','normalized','Position',[0.3 0.2 0.25 0.1]);
display_tab_comp.disp_tracks=uicontrol(display_tab_comp.display_tab,'Style','checkbox','Value',1,'String','Display Tracks','units','normalized','Position',[0.3 0.1 0.25 0.1]);
display_tab_comp.disp_lines=uicontrol(display_tab_comp.display_tab,'Style','checkbox','Value',1,'String','Display Lines','units','normalized','Position',[0.6 0.3 0.3 0.1]);
display_tab_comp.disp_under_bot=uicontrol(display_tab_comp.display_tab,'Style','checkbox','Value',0,'String','Remove Under Bottom data','units','normalized','Position',[0.6 0.4 0.3 0.1]);
%display_tab_comp.switch_bottom=uicontrol(display_tab_comp.display_tab,'Style','checkbox','Value',0,'String','Switch Under Bottom data','units','normalized','Position',[0.6 0.3 0.3 0.1]);

set([display_tab_comp.disp_tracks display_tab_comp.disp_lines display_tab_comp.disp_bad_trans display_tab_comp.disp_bottom display_tab_comp.disp_reg display_tab_comp.disp_under_bot],'callback',{@set_disp,main_figure});

uicontrol(display_tab_comp.display_tab,'Style','pushbutton','String','Disp Attitude','units','normalized','pos',[0.6 0.1 0.15 0.15],'callback',{@display_attitude,main_figure});
uicontrol(display_tab_comp.display_tab,'Style','pushbutton','String','Disp Nav. Data','units','normalized','pos',[0.75 0.1 0.15 0.15],'callback',{@display_navigation_callback,main_figure});

setappdata(main_figure,'Display_tab',display_tab_comp);
end


% 
% function listenChangeEcho(~,~,main_figure)
% display_tab_comp=getappdata(main_figure,'Display_tab');
% curr_disp=getappdata(main_figure,'Curr_disp');
% layer=getappdata(main_figure,'Layer');
% 
% idx_freq=find(layer.Frequencies==curr_disp.Freq);
% if isempty(idx_freq)
%     return
% end
% [idx_field,~]=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);
% if isempty(idx_field)
%     return
% end
% 
% cax=layer.Transceivers(idx_freq).Data.SubData(idx_type).CaxisDisplay;
% set(display_tab_comp.caxis_up,'String',num2str(cax(2),'%.0f'));
% set(display_tab_comp.caxis_down,'String',num2str(cax(1),'%.0f'));
% 
% %update_display(main_figure,0);
% end

% 
% function listenChangeFreq(~,~,main_figure)
% display_tab_comp=getappdata(main_figure,'Display_tab');
% curr_disp=getappdata(main_figure,'Curr_disp');
% layer=getappdata(main_figure,'Layer');
% 
% idx_freq=find(layer.Frequencies==curr_disp.Freq);
% if isempty(idx_freq)
%     return
% end
% 
% [idx_field,~]=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);
% if isempty(idx_field)
%     return
% end
% 
% cax=layer.Transceivers(idx_freq).Data.SubData(idx_type).CaxisDisplay;
% set(display_tab_comp.caxis_up,'String',num2str(cax(2),'%.0f'));
% set(display_tab_comp.caxis_down,'String',num2str(cax(1),'%.0f'));
% 
% main_childs=get(main_figure,'children');
% tags=get(main_childs,'Tag');
% idx_opt=strcmp(tags,'option_tab_panel');
% 
% load_regions_tab(main_figure,main_childs(idx_opt));
% 
% end

function set_caxis(~,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

idx_freq=find(layer.Frequencies==curr_disp.Freq);
if isempty(idx_freq)
    return
end

[idx_field,~]=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);
if isempty(idx_field)
    return
end

cax=str2double(get([display_tab_comp.caxis_down display_tab_comp.caxis_up],'String'));

if cax(2)<cax(1)||isnan(cax(1))||isnan(cax(2))
    cax=layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay;
    set(display_tab_comp.caxis_up,'String',num2str(cax(2),'%.0f'));
    set(display_tab_comp.caxis_down,'String',num2str(cax(1),'%.0f'));
end
curr_disp.Cax=cax;

layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay=[cax(1) cax(2)];
setappdata(main_figure,'Layer',layer);
%update_display(main_figure,0);
load_axis_panel(main_figure,0);
end

function set_disp(~,~,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
curr_disp=getappdata(main_figure,'Curr_disp');
axes_panel_comp=getappdata(main_figure,'Axes_panel');

curr_disp.DispBadTrans=get(display_tab_comp.disp_bad_trans ,'value')==1;
curr_disp.DispReg=get(display_tab_comp.disp_reg ,'value')==1;
curr_disp.DispLines=get(display_tab_comp.disp_lines ,'value')==1;



if get(display_tab_comp.disp_bottom ,'value')
    curr_disp.DispBottom='on';
else
    curr_disp.DispBottom='off';
end

if isfield(axes_panel_comp,'bottom_plot')
    if isvalid(axes_panel_comp.bottom_plot)
        set(axes_panel_comp.bottom_plot,'visible',curr_disp.DispBottom);
    end
end

if get(display_tab_comp.disp_tracks,'value')
    curr_disp.DispTracks='on';
else
    curr_disp.DispTracks='off';
end

if isfield(axes_panel_comp,'track_plot')
    for i=1:length(axes_panel_comp.track_plot)
        if ishandle(axes_panel_comp.track_plot(i))
            set(axes_panel_comp.track_plot(i),'visible',curr_disp.DispTracks);
        else
            axes_panel_comp.track_plot(i)=[];
        end
    end
end

toggle_disp_regions(main_figure);
toggle_disp_lines(main_figure);
setappdata(main_figure,'Curr_disp',curr_disp);
set_alpha_map(main_figure);
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

function display_navigation_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
hfigs=getappdata(main_figure,'ExternalFigures');

hfig=figure('Name','Navigation','NumberTitle','off','tag','nav');

lat=layer.GPSData.Lat;
long=layer.GPSData.Long;

if ~isempty(long)
    figure(hfig);
    m_proj('UTM','long',[nanmin(long)-0.01 nanmax(long)+0.01],'lat',[nanmin(lat)-0.01 nanmax(lat)+0.01]);   
    hold on;
    m_grid('box','fancy','tickdir','in');
    m_plot(long,lat,'color','r');
    %m_gshhs_h('color','k')
else
    close(hfig);
   warning('No navigation data'); 
end
hfigs=[hfigs hfig];
setappdata(main_figure,'ExternalFigures',hfigs);

end