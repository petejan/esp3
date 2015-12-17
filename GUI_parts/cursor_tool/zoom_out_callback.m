function zoom_out_callback(src,~,main_figure)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
obj=gco;

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);
Number=trans.Data.Number;
Range=trans.Data.Range;


xdata_tot=Number;
ydata_tot=Range;

if axes_panel_comp.main_echo==obj
    ah=axes_panel_comp.main_axes;
    if strcmp(src.SelectionType,'normal')
        
        x_lim=get(ah,'XLim');
        y_lim=get(ah,'YLim');
        
        dx=abs(diff(x_lim));
        dy=diff(y_lim);
        
        x_lim(1)=x_lim(1)-dx/4;
        y_lim(1)=y_lim(1)-dy/4;
        x_lim(2)=x_lim(2)+dx/4;
        y_lim(2)=y_lim(2)+dy/4;
        
        x_lim(x_lim>nanmax(xdata_tot))=nanmax(xdata_tot);
        x_lim(x_lim<nanmin(xdata_tot))=nanmin(xdata_tot);
        
        y_lim(y_lim>nanmax(ydata_tot))=nanmax(ydata_tot);
        y_lim(y_lim<nanmin(ydata_tot))=nanmin(ydata_tot);
    elseif strcmp(src.SelectionType,'alt')||strcmp(src.SelectionType,'open')
        x_lim=[nanmin(xdata_tot) nanmax(xdata_tot)];
        y_lim=[nanmin(ydata_tot) nanmax(ydata_tot)];
    end
    set(ah,'XLim',x_lim,'YLim',y_lim);
end


end