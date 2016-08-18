function load_mini_axes(main_figure,parent,pos_in_parent)

if isappdata(main_figure,'Mini_axes')
    mini_axes_comp=getappdata(main_figure,'Mini_axes');
    delete(mini_axes_comp.mini_ax);
    rmappdata(main_figure,'Mini_axes');
end

mini_axes_comp.mini_ax=axes('Parent',parent,'Units','normalized','box','on',...
    'Position',pos_in_parent,'visible','on','NextPlot','add','box','on');
mini_axes_comp.mini_echo=imagesc(1,1,1,'Parent',mini_axes_comp.mini_ax,'tag','echo','AlphaData',0);
mini_axes_comp.mini_echo_bt=image(1,1,1,'Parent',mini_axes_comp.mini_ax,'tag','bad_transmits','AlphaData',0);
mini_axes_comp.patch_obj=patch('Faces',[],'Vertices',[],'FaceColor','r','FaceAlpha',.2,'EdgeColor','r','Tag','zoom_area','Parent',mini_axes_comp.mini_ax);
set(mini_axes_comp.mini_ax,'XTickLabels',[],'YTickLabels',[]);
set(mini_axes_comp.mini_ax,'ButtonDownFcn',{@move_mini_axis_grab,main_figure});
set(mini_axes_comp.patch_obj,'ButtonDownFcn',{@move_patch_mini_axis_grab,main_figure});
set(mini_axes_comp.mini_echo,'ButtonDownFcn',{@zoom_in_callback_mini_ax,main_figure});
set(mini_axes_comp.mini_echo_bt,'ButtonDownFcn',{@zoom_in_callback_mini_ax,main_figure});

if isgraphics(parent,'figure')
    set(parent,'ResizeFcn',{@resize_mini_ax,main_figure});
end

setappdata(main_figure,'Mini_axes',mini_axes_comp);
end