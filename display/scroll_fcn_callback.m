function scroll_fcn_callback(src,callbackdata,main_figure)


echo_tab_panel=getappdata(main_figure,'echo_tab_panel');
curr_obj=gco;
if isfield(curr_obj,'Type')
    type_obj=curr_obj.Type;
else
    type_obj='';
end

if isempty(echo_tab_panel.SelectedTab)
    return;
end

if~strcmpi(echo_tab_panel.SelectedTab.Tag,'axes_panel')||strcmp(type_obj,'uitable')
    return;
end

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    %disp('Empty')
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;


x_lim=get(ah,'XLim');
y_lim=get(ah,'YLim');

if src==main_figure
    set(ah,'units','pixels');
    pos=ah.CurrentPoint(1,1:2);
    set(ah,'units','normalized');
else
    pos=[nanmean(x_lim) nanmean(y_lim)];
end


if any(pos<0)
    return;
end


curr_disp=getappdata(main_figure,'Curr_disp');

trans=layer.get_trans(curr_disp);

xdata_tot=trans.get_transceiver_pings();
ydata_tot=trans.get_transceiver_samples();

[x_lim,y_lim]=compute_xylim_zoom(x_lim,y_lim,'VerticalScrollCount',callbackdata.VerticalScrollCount,...
    'x_lim_tot',[xdata_tot(1) xdata_tot(end)],'y_lim_tot',[ydata_tot(1) ydata_tot(end)],...
    'Position',pos);


if diff(x_lim)<=0||diff(y_lim)<=0
    return;
end
set(ah,'XLim',x_lim,'YLim',y_lim);


end