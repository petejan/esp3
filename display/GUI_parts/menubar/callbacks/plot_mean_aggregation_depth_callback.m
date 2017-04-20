function plot_mean_aggregation_depth_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans_obj=layer.trans_objs(idx_freq);
list_reg = trans_obj.regions_to_str();

if strcmp(curr_disp.Fieldname,'sv')
    cax=curr_disp.Cax;
else
    [cax,~]=init_cax('sv');
end

if ~isempty(list_reg)
    active_reg=trans_obj.Regions(get(region_tab_comp.tog_reg,'value'));
    
    [mean_depth,Sa]=trans_obj.get_mean_depth_from_region(active_reg.Unique_ID);
    
    Sv=trans_obj.Data.get_datamat('sv');
    range=trans_obj.get_transceiver_range();
    bot_r=trans_obj.get_bottom_range;
    bot_r(bot_r==0)=range(end);
    bot_r(isnan(bot_r))=range(end);
    
   idx_pings=active_reg.Idx_pings;
   idx_r=active_reg.Idx_r;
    time=datetime(datestr(trans_obj.Data.Time(idx_pings)));
    range=trans_obj.get_transceiver_range(idx_r);
    new_echo_figure(main_figure);
    ax1=subplot(2,1,1);
    u=imagesc(trans_obj.Data.Time(idx_pings),range,Sv(idx_r,idx_pings));
    hold on;
    plot(time,mean_depth,'r','linewidth',2);
    plot(time,bot_r(idx_pings))
    ylabel('Depth (m)')
    xlabel('Time')

    caxis(cax)
    colormap(jet);
    set(u,'alphadata',Sv(idx_r,idx_pings)>=cax(1));  
    ax2=subplot(2,1,2);
    plot(time,Sa,'k','linewidth',2);

    ylabel('S_a (dB re 1(m2 m-2))')
    xlabel('Time')
    grid on;
    linkaxes([ax1 ax2],'x')
    
else
    return
end

end