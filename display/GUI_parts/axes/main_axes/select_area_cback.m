function select_area_cback(src,~,main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;

modifiers = get(src,'CurrentModifier');
control = ismember('control',   modifiers);


if control
    mode='rectangular';
else
    return;
end

switch curr_disp.Cmap
    case 'esp2'
        col_line='w';
    otherwise
        col_line='k';
end



clear_lines(ah);
u=findobj(ah,'Type','line','-and','Tag','SelectLine');
delete(u);

xdata=get(axes_panel_comp.main_echo,'XData');
ydata=get(axes_panel_comp.main_echo,'YData');
cp = ah.CurrentPoint;

switch mode
    case 'rectangular'
        xinit = cp(1,1);
        yinit = cp(1,2);
    case 'horizontal'
        xinit = xdata(1);
        yinit = cp(1,2);
    case 'vertical'
        xinit = cp(1,1);
        yinit = ydata(1);
end


if xinit<xdata(1)||xinit>xdata(end)||yinit<ydata(1)||yinit>ydata(end)
    return;
end

x_box=xinit;
y_box=yinit;


hp=line(x_box,y_box,'color',col_line,'linewidth',1,'parent',ah,'LineStyle','--','Tag','SelectLine');


src.WindowButtonMotionFcn = @wbmcb;
src.WindowButtonUpFcn = @wbucb;
order_axes(main_figure);

    function wbmcb(~,~)
        cp = ah.CurrentPoint;
        
        
        switch mode
            case 'rectangular'
                X = [xinit,cp(1,1)];
                Y = [yinit,cp(1,2)];
            case 'horizontal'
                X = [xinit,xdata(end)];
                Y = [yinit,cp(1,2)];
            case 'vertical'
                X = [xinit,cp(1,1)];
                Y = [yinit,ydata(end)];
                
        end
        
        x_min=nanmin(X);
        x_min=nanmax(xdata(1),x_min);
        
        x_max=nanmax(X);
        x_max=nanmin(xdata(end),x_max);
        
        y_min=nanmin(Y);
        y_min=nanmax(y_min,ydata(1));
        
        y_max=nanmax(Y);
        y_max=nanmin(y_max,ydata(end));
        
        x_box=([x_min x_max  x_max x_min x_min]);
        y_box=([y_max y_max y_min y_min y_max]);
        
        set(hp,'XData',x_box,'YData',y_box);
        
        
    end

    function wbucb(src,~)
        
        src.WindowButtonMotionFcn = '';
        src.WindowButtonUpFcn = '';
        
        create_select_area_context_menu(hp,main_figure)
        
        reset_disp_info(main_figure);
        
    end

end