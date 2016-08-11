function scroll_fcn_callback(src,callbackdata)
main_figure=src;
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');

ah=axes_panel_comp.main_axes;

pos=ah.CurrentPoint(1,1:2);

if nansum(pos<0)>0
    return;
end

x_lim=get(ah,'XLim');
y_lim=get(ah,'YLim');


dx=abs(diff(x_lim));
dy=diff(y_lim);



curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

set(axes_panel_comp.main_axes,'units','pixels');

set(axes_panel_comp.main_axes,'units','normalized');

xdata_tot=trans.Data.get_numbers();
ydata_tot=trans.Data.get_range();



if callbackdata.VerticalScrollCount>0
    
    x_lim(1)=x_lim(1)-dx/2;
    y_lim(1)=y_lim(1)-dy/2;
    x_lim(2)=x_lim(2)+dx/2;
    y_lim(2)=y_lim(2)+dy/2;
    
    x_lim(x_lim>nanmax(xdata_tot))=nanmax(xdata_tot);
    x_lim(x_lim<nanmin(xdata_tot))=nanmin(xdata_tot);
    
    y_lim(y_lim>nanmax(ydata_tot))=nanmax(ydata_tot);
    y_lim(y_lim<nanmin(ydata_tot))=nanmin(ydata_tot);
else
    
    x_lim(1)=pos(1)-dx/4;
    y_lim(1)=pos(2)-dy/4;
    x_lim(2)=pos(1)+dx/4;
    y_lim(2)=pos(2)+dy/4;
    
end

x_lim(x_lim>nanmax(xdata_tot))=nanmax(xdata_tot);
x_lim(x_lim<nanmin(xdata_tot))=nanmin(xdata_tot);

y_lim(y_lim>nanmax(ydata_tot))=nanmax(ydata_tot);
y_lim(y_lim<nanmin(ydata_tot))=nanmin(ydata_tot);

set(ah,'XLim',x_lim,'YLim',y_lim);
reset_disp_info(main_figure);

end