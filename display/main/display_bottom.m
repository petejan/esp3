

function axes_panel_comp=display_bottom(xdata,Range_bottom,axes_panel_comp,vis)

if~isempty(Range_bottom)&&~isempty(xdata)
    if isfield(axes_panel_comp,'bottom_plot')
        if ishandle(axes_panel_comp.bottom_plot)
            delete(axes_panel_comp.bottom_plot);
            axes_panel_comp.bottom_plot=plot(xdata,Range_bottom,'k','linewidth',2,'tag','bottom','visible',vis);
            set(axes_panel_comp.bottom_plot,'visible',vis);
        else
            axes_panel_comp.bottom_plot=plot(xdata,Range_bottom,'k','linewidth',2,'tag','bottom','visible',vis);
        end
    else
        axes_panel_comp.bottom_plot=plot(xdata,Range_bottom,'k','linewidth',2,'tag','bottom','visible',vis);
        
    end
end

end
