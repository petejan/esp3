function display_bottom(xdata,ydata,idx_bottom,axes_panel_comp,vis,col)
if~isempty(idx_bottom)&&~isempty(xdata)&&~isempty(ydata)
    x=linspace(xdata(1),xdata(end),length(xdata));
    %x(isnan(idx_bottom))=[];
    y=nan(size(x));
    y(~isnan(idx_bottom))=ydata(idx_bottom(~isnan(idx_bottom)));

    set(axes_panel_comp.bottom_plot,'XData',x,'YData',y,'visible',vis,'color',col);

end

end
