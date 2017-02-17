function load_mini_axes(main_figure,parent,pos_in_parent)

if isappdata(main_figure,'Mini_axes')
    mini_axes_comp=getappdata(main_figure,'Mini_axes');
    delete(mini_axes_comp.mini_ax);
    rmappdata(main_figure,'Mini_axes');
end


pointerBehavior.enterFcn =  @(figHandle, currentPoint)...
    set(figHandle, 'Pointer', 'fleur');
pointerBehavior.exitFcn  = @(figHandle, currentPoint)...
    set(figHandle, 'Pointer', 'fleur');
pointerBehavior.traverseFcn = @(figHandle, currentPoint)...
    set(figHandle, 'Pointer', 'fleur');

mini_axes_comp.mini_ax=axes('Parent',parent,'Units','normalized','box','on',...
    'Position',pos_in_parent,'visible','on','NextPlot','add','box','on');

%iptSetPointerBehavior(mini_axes_comp.mini_ax,pointerBehavior);

mini_axes_comp.mini_echo=imagesc(1,1,1,'Parent',mini_axes_comp.mini_ax,'tag','echo','AlphaData',0);
mini_axes_comp.mini_echo_bt=image(1,1,1,'Parent',mini_axes_comp.mini_ax,'tag','bad_transmits','AlphaData',0);
mini_axes_comp.bottom_plot=plot(mini_axes_comp.mini_ax,nan,'tag','bottom');
mini_axes_comp.patch_obj=patch('Faces',[],'Vertices',[],'FaceColor','r','FaceAlpha',.2,'EdgeColor','r','Tag','zoom_area','Parent',mini_axes_comp.mini_ax);

iptSetPointerBehavior(mini_axes_comp.patch_obj,pointerBehavior);

set(mini_axes_comp.mini_ax,'XTickLabels',[],'YTickLabels',[]);

set(mini_axes_comp.patch_obj,'ButtonDownFcn',{@move_patch_mini_axis_grab,main_figure});
set(mini_axes_comp.mini_echo,'ButtonDownFcn',{@zoom_in_callback_mini_ax,main_figure});
set(mini_axes_comp.mini_echo_bt,'ButtonDownFcn',{@zoom_in_callback_mini_ax,main_figure});

if isgraphics(parent,'figure')
    set(parent,'SizeChangedFcn',{@resize_mini_ax,main_figure});
else
    set(mini_axes_comp.mini_ax,'ButtonDownFcn',{@move_mini_axis_grab,main_figure});
end

setappdata(main_figure,'Mini_axes',mini_axes_comp);
create_context_menu_mini_echo(main_figure);
end