function plot_mean_aggregation_depth_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = list_regions(layer.Transceivers(idx_freq));
idx_field=find_field_idx(layer.Transceivers(idx_freq).Data,'sv');
cax=layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay;


if ~isempty(list_reg)
    active_reg=Transceiver.Regions(get(region_tab_comp.tog_reg,'value'));
    
    Sv=layer.Transceivers(idx_freq).Data.get_datamat('sv');
    Sv_ori=Sv;
    idx=list_regions_type(Transceiver,'Bad Data');
    
    for i=idx
        curr_reg=layer.Transceivers(idx_freq).Regions(i);
        
        idx_r_curr=curr_reg.Sample_ori:curr_reg.Sample_ori+curr_reg.BBox_h-1;
        idx_pings_curr=curr_reg.Ping_ori-layer.Transceivers(idx_freq).Data.Number(1)+1:curr_reg.Ping_ori+curr_reg.BBox_w-layer.Transceivers(idx_freq).Data.Number(1);
        switch curr_reg.Shape
            case 'Rectangular'
                Sv(idx_r_curr,idx_pings_curr)=NaN;
            case 'Polygon'
                Sv(idx_r_curr,idx_pings_curr)=curr_reg.Sv_reg;
        end
    end
    
    Sv(:,Transceiver.IdxBad)=NaN;
    bot_r=Transceiver.Bottom.Range;
    bot_r(bot_r==0)=layer.Transceivers(idx_freq).Data.Range(end);
    bot_r(isnan(bot_r))=layer.Transceivers(idx_freq).Data.Range(end);
    
    Sv(repmat(bot_r,size(Sv,1),1)<=repmat(layer.Transceivers(idx_freq).Data.Range,1,size(Sv,2)))=NaN;
    
    
    
    idx_r=active_reg.Sample_ori:active_reg.Sample_ori+active_reg.BBox_h-1;
    idx_pings=active_reg.Ping_ori-layer.Transceivers(idx_freq).Data.Number(1)+1:active_reg.Ping_ori+active_reg.BBox_w-layer.Transceivers(idx_freq).Data.Number(1);
      
    
    Sv_reg=Sv(idx_r,idx_pings);
    Sv_reg(Sv_reg<cax(1))=nan;
    range=double(layer.Transceivers(idx_freq).Data.Range(idx_r));
    Sa=10*log10(nansum(10.^(Sv_reg/10).*nanmean(diff(range))));
    Sv_mean=10*log10(nanmean(10.^(Sv_reg/10).*nanmean(diff(range))));
    
    mean_depth= nansum(10.^(Sv_reg/20).*repmat(range,1,size(Sv_reg,2)))./nansum(10.^(Sv_reg/20));
    mean_depth(Sa<-70)=NaN;
    pings_num=double(idx_pings+layer.Transceivers(idx_freq).Data.Number(1)-1);
    time=datetime(datestr(layer.Transceivers(idx_freq).Data.Time(idx_pings)));
    
    figure();
    ax1=subplot(2,1,1);
    u=imagesc(layer.Transceivers(idx_freq).Data.Time(idx_pings),range,Sv_ori(idx_r,idx_pings));
    hold on;
    %plot(pings_num,mean_depth,'k','linewidth',2);
    plot(time,bot_r(idx_pings))
    plot(time,filter2(ones(1,100),mean_depth)./filter2(ones(1,100),ones(size(mean_depth))),'r','linewidth',2);
    %atetick('x','HH:MM','keepticks','keeplimits')
    ylabel('Depth (m)')
    xlabel('Time')
    %plot(pings_num,filter2_perso(ones(1,100),mean_depth),'r','linewidth',2);
    caxis(cax)
    colormap(jet);
    set(u,'alphadata',Sv_ori(idx_r,idx_pings)>=cax(1));  
    ax2=subplot(2,1,2);
    plot(time,10*log10(filter2(ones(1,100),10.^(Sa/10))./filter2(ones(1,100),ones(size(Sa)))),'k','linewidth',2);
    %datetick('x','HH:MM','keepticks','keeplimits')
    ylabel('S_a (dB re 1(m2 m-2))')
    xlabel('Time')
    grid on;
    linkaxes([ax1 ax2],'x')
    
else
    return
end

end