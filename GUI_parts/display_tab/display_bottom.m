function axes_panel_comp=display_bottom(xdata,ydata,idx_bottom,axes_panel_comp,vis)
if~isempty(idx_bottom)&&~isempty(xdata)&&~isempty(ydata)
    x=linspace(xdata(1),xdata(end),length(xdata));
    %x(isnan(idx_bottom))=[];
    y=nan(size(x));
    y(~isnan(idx_bottom))=ydata(idx_bottom(~isnan(idx_bottom)));
    if isfield(axes_panel_comp,'bottom_plot')
        if ishandle(axes_panel_comp.bottom_plot)
            delete(axes_panel_comp.bottom_plot);
            axes_panel_comp.bottom_plot=plot(x,y,'k','linewidth',2,'tag','bottom','visible',vis);
            set(axes_panel_comp.bottom_plot,'visible',vis);
        else
            axes_panel_comp.bottom_plot=plot(x,y,'k','linewidth',2,'tag','bottom','visible',vis);
        end
    else
        axes_panel_comp.bottom_plot=plot(x,y,'k','linewidth',2,'tag','bottom','visible',vis);
    end
end

end
