function scroll_fcn_callback(src,callbackdata,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
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

dx=abs(diff(x_lim));
dy=diff(y_lim);

curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

xdata_tot=trans.Data.get_numbers();
ydata_tot=trans.Data.get_range();

if callbackdata.VerticalScrollCount>0
    
    x_lim(1)=x_lim(1)-dx/4;
    y_lim(1)=y_lim(1)-dy/4;
    x_lim(2)=x_lim(2)+dx/4;
    y_lim(2)=y_lim(2)+dy/4;
    
else
    
    x_lim(1)=pos(1)-3*dx/8;
    y_lim(1)=pos(2)-3*dy/8;
    x_lim(2)=pos(1)+3*dx/8;
    y_lim(2)=pos(2)+3*dy/8;
    
    dx_new=abs(diff(x_lim));
    dy_new=diff(y_lim);
    
    if any(x_lim>nanmax(xdata_tot))
        x_lim=[nanmax(xdata_tot)-dx_new nanmax(xdata_tot)];
    end
    
   if any(x_lim<nanmin(xdata_tot))
        x_lim=[nanmin(xdata_tot) dx_new+nanmin(xdata_tot)];
   end
    
     if any(y_lim>nanmax(ydata_tot))
        y_lim=[nanmax(ydata_tot)-dy_new nanmax(ydata_tot)];
    end
    
   if any(y_lim<nanmin(ydata_tot))
        y_lim=[nanmin(ydata_tot) dy_new+nanmin(ydata_tot)];
    end
end

x_lim(x_lim>nanmax(xdata_tot))=nanmax(xdata_tot);
x_lim(x_lim<nanmin(xdata_tot))=nanmin(xdata_tot);

y_lim(y_lim>nanmax(ydata_tot))=nanmax(ydata_tot);
y_lim(y_lim<nanmin(ydata_tot))=nanmin(ydata_tot);

if diff(x_lim)<=0||diff(y_lim)<=0
    return;
end

set(ah,'XLim',x_lim,'YLim',y_lim);
reset_disp_info(main_figure);

end