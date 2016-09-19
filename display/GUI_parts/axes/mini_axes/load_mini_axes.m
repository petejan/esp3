function load_mini_axes(main_figure,parent,pos_in_parent)
if isappdata(main_figure,'Mini_axes')
    mini_axes_comp=getappdata(main_figure,'Mini_axes');
    delete(mini_axes_comp.mini_ax);
    delete(mini_axes_comp.undock_button);
    rmappdata(main_figure,'Mini_axes');
end

mini_axes_comp.mini_ax=axes('Parent',parent,'Units','normalized','box','on',...
    'Position',pos_in_parent,'visible','on','NextPlot','add','box','on');
mini_axes_comp.mini_echo=imagesc(1,1,1,'Parent',mini_axes_comp.mini_ax,'tag','echo','AlphaData',0);
mini_axes_comp.mini_echo_bt=image(1,1,1,'Parent',mini_axes_comp.mini_ax,'tag','bad_transmits','AlphaData',0);
mini_axes_comp.bottom_plot=plot(mini_axes_comp.mini_ax,nan,'tag','bottom');
mini_axes_comp.patch_obj=patch('Faces',[],'Vertices',[],'FaceColor','r','FaceAlpha',.2,'EdgeColor','r','Tag','zoom_area','Parent',mini_axes_comp.mini_ax);
set(mini_axes_comp.mini_ax,'XTickLabels',[],'YTickLabels',[]);

set(mini_axes_comp.patch_obj,'ButtonDownFcn',{@move_patch_mini_axis_grab,main_figure});
set(mini_axes_comp.mini_echo,'ButtonDownFcn',{@zoom_in_callback_mini_ax,main_figure});
set(mini_axes_comp.mini_echo_bt,'ButtonDownFcn',{@zoom_in_callback_mini_ax,main_figure});

app_path_main=whereisEcho();
icon=get_icons_cdata(fullfile(app_path_main,'icons'));

if isgraphics(parent,'figure')
    set(parent,'ResizeFcn',{@resize_mini_ax,main_figure});
    hfigs=getappdata(main_figure,'ExternalFigures');
    hfigs=[parent hfigs];
    setappdata(main_figure,'ExternalFigures',hfigs);
else
    set(mini_axes_comp.mini_ax,'ButtonDownFcn',{@move_mini_axis_grab,main_figure});
end

undoc_cdata_size=size(icon.undock);
set(mini_axes_comp.mini_ax,'Units','pixels');
mini_axes_comp.undock_button=uicontrol(parent,'Style','pushbutton','position',[mini_axes_comp.mini_ax.Position(3:4)-undoc_cdata_size(1:2) undoc_cdata_size(1:2)],...
    'cdata',icon.undock,'callback',{@undock_mini_axes_callback,main_figure},'Tooltipstring','Un-dock/Dock Mini Axes','visible','off');
set(mini_axes_comp.mini_ax,'Units','normalized');

setappdata(main_figure,'Mini_axes',mini_axes_comp);
end