function listenCax(~,listdata,main_figure)

set_alpha_map(main_figure);

if ~isempty(listdata.AffectedObject.Cax)
    axes_panel_comp=getappdata(main_figure,'Axes_panel');
    axes(axes_panel_comp.main_axes);
    caxis(listdata.AffectedObject.Cax);
end

update_mini_ax(main_figure,0);
end