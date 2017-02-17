function go_to_ping(idx_ping,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;


curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

xdata=trans.Data.get_numbers();

x_lim=[xdata(idx_ping) xdata(idx_ping)+diff(get(ah,'XLim'))];

if any(x_lim>xdata(end))
    x_lim=[xdata(end)-diff(get(ah,'XLim')) xdata(end)];
end

if diff(x_lim)<=0
    return;
end

set(ah,'XLim',x_lim,'YLim',get(ah,'YLim'));


end