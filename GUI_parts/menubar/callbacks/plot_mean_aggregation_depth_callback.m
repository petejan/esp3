function plot_mean_aggregation_depth_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = list_regions(layer.Transceivers(idx_freq));
idx_field=find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
cax=layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay;


if ~isempty(list_reg)
    active_reg=Transceiver.Regions(get(region_tab_comp.tog_reg,'value'));
    
    [mean_depth,Sa]=Transceiver.get_mean_depth_from_region(active_reg.Unique_ID);
    
    Sv=layer.Transceivers(idx_freq).Data.get_datamat('sv');

    bot_r=Transceiver.Bottom.Range;
    bot_r(bot_r==0)=layer.Transceivers(idx_freq).Data.Range(end);
    bot_r(isnan(bot_r))=layer.Transceivers(idx_freq).Data.Range(end);
    
   idx_pings=active_reg.Idx_pings;
   idx_r=active_reg.Idx_r;
    time=datetime(datestr(layer.Transceivers(idx_freq).Data.Time(idx_pings)));
    range=layer.Transceivers(idx_freq).Data.Range(idx_r);
    figure();
    ax1=subplot(2,1,1);
    u=imagesc(layer.Transceivers(idx_freq).Data.Time(idx_pings),range,Sv(idx_r,idx_pings));
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