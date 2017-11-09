function display_file_lines(main_figure)
main_menu=getappdata(main_figure,'main_menu');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);


idx_change_file=find(diff(trans_obj.Data.FileId)>0);

state_file_lines=get(main_menu.display_file_lines,'checked');
trans_obj=trans_obj;
xdata=trans_obj.get_transceiver_pings();
ydata=trans_obj.get_transceiver_samples();

obj_line=findobj(axes_panel_comp.main_axes,'Tag','file_id');
delete(obj_line);

for ifile=1:length(idx_change_file)
    plot(axes_panel_comp.main_axes,xdata(idx_change_file(ifile)).*ones(size(ydata)),ydata,'k','Tag','file_id');
end

obj_line=findobj(axes_panel_comp.main_axes,'Tag','file_id');

for i=1:length(obj_line)
    set(obj_line(i),'vis',state_file_lines); 
end

end
