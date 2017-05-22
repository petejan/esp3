function disp_loc(src,~,main_figure)

obj=gco;

axes_panel_comp=getappdata(main_figure,'Axes_panel');
ah=axes_panel_comp.main_axes;

if strcmp(src.SelectionType,'normal')&&axes_panel_comp.main_echo==obj
    
    u=get(ah,'children');
    
    for ii=1:length(u)
        if (isa(u(ii),'matlab.graphics.primitive.Line')||isa(u(ii),'matlab.graphics.chart.primitive.Line'))&&~strcmp(get(u(ii),'tag'),'bottom')...
                &&~strcmp(get(u(ii),'tag'),'region')
            delete(u(ii));
        end
    end
    drawnow;
    xdata=get(axes_panel_comp.main_echo,'XData');
    ydata=get(axes_panel_comp.main_echo,'YData');
    cp = ah.CurrentPoint;
    
    xinit = cp(1,1);
    yinit = cp(1,2);
    
    
    
    if xinit<xdata(1)||xinit>xdata(end)||yinit<ydata(1)||yinit>ydata(end)
        return;
    end
    
    replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',1,'interaction_fcn',@wbucb);
    
else
    
    replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',1);
    
end


    function wbucb(~,~)
        
        cp = ah.CurrentPoint;
        
        xinit = cp(1,1);
        yinit = cp(1,2);
        
        
        if xinit<xdata(1)||xinit>xdata(end)||yinit<ydata(1)||yinit>ydata(end)
            return;
        end
        
        layer=getappdata(main_figure,'Layer');
        curr_disp=getappdata(main_figure,'Curr_disp');
        
        idx_freq=find_freq_idx(layer,curr_disp.Freq);
        
        curr_gps=layer.Transceivers(idx_freq).GPSDataPing;
        
        [~,idx_pings]=nanmin(abs(double(xdata)-xinit));
        
        (fprintf('%.6f \n%.6f\n',curr_gps.Lat(idx_pings),curr_gps.Long(idx_pings)));
        
    end

end