function keyboard_zoom(plus_or_minus,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;

x_lim=get(ah,'XLim');
y_lim=get(ah,'YLim');

curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

xdata_tot=trans.get_transceiver_pings();
ydata_tot=trans.get_transceiver_samples();

[x_lim,y_lim]=compute_xylim_zoom(x_lim,y_lim,'VerticalScrollCount',plus_or_minus,...
    'x_lim_tot',[xdata_tot(1) xdata_tot(end)],'y_lim_tot',[ydata_tot(1) ydata_tot(end)]);


if diff(x_lim)<=0||diff(y_lim)<=0
    return;
end

set(ah,'XLim',x_lim,'YLim',y_lim);


end