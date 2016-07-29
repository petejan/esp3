function toggle_display_file_lines(main_figure)
main_menu=getappdata(main_figure,'main_menu');
axes_panel_comp=getappdata(main_figure,'Axes_panel');

state_file_lines=get(main_menu.display_file_lines,'checked');

obj_line=findobj(axes_panel_comp.main_axes,'Tag','file_id');

for i=1:length(obj_line)
    set(obj_line(i),'vis',state_file_lines); 
end

end
