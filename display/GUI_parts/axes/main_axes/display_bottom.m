function display_bottom(main_figure)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.Transceivers(idx_freq);
idx_bottom=trans_obj.Bottom.Sample_idx;
xdata=trans_obj.Data.get_numbers();
ydata=trans_obj.Data.get_range();


if strcmpi(curr_disp.CursorMode,'Normal')
    create_context_menu_bottom(main_figure,axes_panel_comp.bottom_plot);
end

if~isempty(idx_bottom)&&~isempty(xdata)&&~isempty(ydata)
    x=linspace(xdata(1),xdata(end),length(xdata));
    %x(isnan(idx_bottom))=[];
    y=nan(size(x));
    y(~isnan(idx_bottom))=ydata(idx_bottom(~isnan(idx_bottom))); 
    set(axes_panel_comp.bottom_plot,'XData',x,'YData',y,'visible',curr_disp.DispBottom);
else
    set(axes_panel_comp.bottom_plot,'XData',nan,'YData',nan,'visible',curr_disp.DispBottom);
end

end
