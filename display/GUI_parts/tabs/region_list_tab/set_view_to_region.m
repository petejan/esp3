function set_view_to_region(ID,main_figure)

if isempty(ID)
    return;
end
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);

reg_curr=trans_obj.get_region_from_Unique_ID(ID);

if~isdeployed()
    fprintf('Set View to region %.0f\n',reg_curr.ID);
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');


xdata=trans_obj.get_transceiver_pings();
ydata=trans_obj.get_transceiver_samples();

x_reg_lim=xdata(reg_curr.Idx_pings);
y_reg_lim=ydata(reg_curr.Idx_r);


ah=axes_panel_comp.main_axes;
x_lim=get(ah,'xlim');
y_lim=get(ah,'ylim');

if all(x_reg_lim>x_lim(2)|x_reg_lim<x_lim(1))||all(y_reg_lim>y_lim(2)|y_reg_lim<y_lim(1))
    
    dx=diff(x_lim);
    dy=diff(y_lim);
    
    x_lim_new= [nanmean(x_reg_lim)-dx/2 nanmean(x_reg_lim)+dx/2];
    y_lim_new= [nanmean(y_reg_lim)-dy/2 nanmean(y_reg_lim)+dy/2];
    
    if any(x_lim_new<xdata(1))
        x_lim_new=[1 dx];
    end
            
    if any(y_lim_new<ydata(1))
        y_lim_new=[1 dy];
    end
    
    if any(x_lim_new>xdata(end))
        x_lim_new=[xdata(end)-dx+1 xdata(end)];
    end
    
       
    if any(y_lim_new>ydata(end))
        y_lim_new=[ydata(end)-dy+1 ydata(end)];
    end
    
    set(ah,'XLim',x_lim_new,'YLim',y_lim_new);
    
end