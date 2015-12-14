function listenCax(src,listdata,main_figure)
%disp('ListenCax')
axes_panel_comp=getappdata(main_figure,'Axes_panel');
axes(axes_panel_comp.main_axes);
set_alpha_map(main_figure);
if ~isempty(listdata.AffectedObject.Cax)
    caxis(listdata.AffectedObject.Cax);
end
end