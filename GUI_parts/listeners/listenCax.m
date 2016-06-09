function listenCax(~,listdata,main_figure)
%disp('ListenCax')
axes_panel_comp=getappdata(main_figure,'Axes_panel');

axes(axes_panel_comp.main_axes);
set_alpha_map(main_figure);

if ~isempty(listdata.AffectedObject.Cax)
    caxis(listdata.AffectedObject.Cax);
end

display_tab_comp=getappdata(main_figure,'Display_tab');
set_alpha_map(main_figure,'echo_ax',display_tab_comp.mini_ax,'echo_im',display_tab_comp.mini_echo);
end