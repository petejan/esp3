function select_area_cback(src,~,main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
ah=axes_panel_comp.main_axes;


switch src.SelectionType
    case 'normal'
        
        return;
       
    case 'alt'
        
        modifier = get(src,'CurrentModifier');
        control = ismember({'control','shift'},modifier);
            
        if control(1)
            mode='rectangular'; 
        else
            return;
        end
        
    case 'extend'
         mode='horizontal';
    case 'open'
        clear_lines(ah);
        u=findobj(ah,'Tag','SelectLine','-or','Tag','SelectArea');
        delete(u);
        return;
end

clear_lines(ah);
u=findobj(ah,'Tag','SelectLine','-or','Tag','SelectArea');
delete(u);


switch curr_disp.Cmap
    case 'esp2'
        col='w';
    otherwise
        col=[0.5 0.5 0.5];
end





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


hp=line(x_box,y_box,'color',col,'linewidth',1,'parent',ah,'LineStyle','--','Tag','SelectLine');


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
        delete(hp);
%         cdata=zeros(2,2,3);
%         cdata(:,:,1)=col(1);
%         cdata(:,:,2)=col(2);
%         cdata(:,:,3)=col(3);
%         
%         x_min=nanmin(x_box);
%         x_max=nanmax(x_box);
%         
%         y_min=nanmin(y_box);
%         y_max=nanmax(y_box);
%         
%         hp_a=image('XData',[x_min x_max],'YData',[y_min y_max],'CData',cdata,'parent',ah,'tag','SelectArea','AlphaData',0.2);

switch mode
    case 'horizontal'
        [idx_freq,~]=layer.find_freq_idx(curr_disp.Freq);
        x=layer.Transceivers(idx_freq).Data.get_numbers();
        x_box=([x(1) x(end)  x(end) x(1) x(1)]);
    case 'vertical'
    otherwise
end
        hp_a=patch(ah,'XData',x_box,'YData',y_box,'FaceColor',col,'tag','SelectArea','FaceAlpha',0.5,'EdgeColor',col);
        %plot(main_axes,x_reg_rect,y_reg_rect,'color',col,'LineWidth',1,'Tag','region_cont','UserData',reg_curr.Unique_ID);
                
        %create_select_area_context_menu(hp,main_figure);
        
        create_select_area_context_menu(hp_a,main_figure)
        
        reset_disp_info(main_figure);
        
    end

end