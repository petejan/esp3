function h_figs=apply_classification(layer,idx_freq,idx_school)

[idx_38,found_38]=find_freq_idx(layer,38000);
[idx_18,found_18]=find_freq_idx(layer,18000);
[idx_120,found_120]=find_freq_idx(layer,120000);

if ~found_18||~found_120||~found_38
    warning('Cannot find every frequencies! Pass...');
    h_figs=[];
    return;
end

school_reg=layer.Transceivers(idx_freq).Regions(idx_school);
layer.copy_region_across(idx_freq,school_reg,[idx_38,idx_18,idx_120]);

[idx_school_18,found_18]=layer.Transceivers(idx_18).find_reg_name_id(school_reg.Name,school_reg.ID);
[idx_school_38,found_38]=layer.Transceivers(idx_38).find_reg_name_id(school_reg.Name,school_reg.ID);
[idx_school_120,found_120]=layer.Transceivers(idx_120).find_reg_name_id(school_reg.Name,school_reg.ID);

if ~found_18||~found_120||~found_38
    warning('Cannot find school on every frequency!Pass...');
    h_figs=[];
    return;
end

school_18_reg=layer.Transceivers(idx_18).Regions(idx_school_18);
school_38_reg=layer.Transceivers(idx_38).Regions(idx_school_38);
school_120_reg=layer.Transceivers(idx_120).Regions(idx_school_120);

delta_120_18=school_120_reg.Output.Sv_mean-school_18_reg.Output.Sv_mean;
delta_120_38=school_120_reg.Output.Sv_mean-school_38_reg.Output.Sv_mean;

if nansum(~isnan(delta_120_38(:)))>50
    h_figs(1)=figure('Name',sprintf('School %d',idx_school_38),'NumberTitle','off','tag','classif');
    ax1=subplot(2,1,1);
    pcolor(school_120_reg.Output.x_node,school_120_reg.Output.Range_mean,delta_120_38);
    colormap(jet);
    grid on;
    xlabel(school_38_reg.Cell_w_unit)
    ylabel('Depth(m)')
    hold on;
    axis ij;
    caxis([-10 10]);
    colorbar;
    title(sprintf('\\Delta 120-38 dB difference of school %.0f',idx_school_38));

    ax2=subplot(2,1,2);
    pcolor(school_120_reg.Output.x_node,school_120_reg.Output.Range_mean,delta_120_18);
    xlabel(school_38_reg.Cell_w_unit)
    ylabel('Depth(m)')
    colormap(jet)
    grid on;
    hold on;
    axis ij;
    title(sprintf('\\Delta 120-18 dB difference of school %.0f',idx_school_38));
    caxis([-10 10]);
    colorbar;  
    linkaxes([ax1 ax2],'xy')
    
    
    aggregation_depth=nanmean(school_38_reg.Output.Range_mean(:));
    upper_range=nanmax(school_38_reg.Output.Range_mean(:));
    lat_mean=nanmax(school_38_reg.Output.Lat_M(:));
    bot_depth=nanmean(layer.Transceivers(idx_18).Bottom.Range);
    
    if nanmean(delta_120_18(:))>8&&nanmean(delta_120_38(:))>5
        layer.Transceivers(idx_18).Regions(idx_school_18).Tag='EUP';
        layer.Transceivers(idx_38).Regions(idx_school_38).Tag='EUP';
        layer.Transceivers(idx_120).Regions(idx_school_120).Tag='EUP';
    elseif aggregation_depth>400
        layer.Transceivers(idx_18).Regions(idx_school_18).Tag='DIA';
        layer.Transceivers(idx_38).Regions(idx_school_38).Tag='DIA';
        layer.Transceivers(idx_120).Regions(idx_school_120).Tag='DIA';
    elseif upper_range<200
        layer.Transceivers(idx_18).Regions(idx_school_18).Tag='MMU';
        layer.Transceivers(idx_38).Regions(idx_school_38).Tag='MMU';
        layer.Transceivers(idx_120).Regions(idx_school_120).Tag='MMU';
    elseif bot_depth>400&&lat_mean<-44
        layer.Transceivers(idx_18).Regions(idx_school_18).Tag='ELC';
        layer.Transceivers(idx_38).Regions(idx_school_38).Tag='ELC';
        layer.Transceivers(idx_120).Regions(idx_school_120).Tag='ELC';
    else
        layer.Transceivers(idx_18).Regions(idx_school_18).Tag='LHE';
        layer.Transceivers(idx_38).Regions(idx_school_38).Tag='LHE';
        layer.Transceivers(idx_120).Regions(idx_school_120).Tag='LHE';
        
    end
    
else
    h_figs=[];
    layer.Transceivers(idx_18).Regions(idx_school_18).Tag='UNC';
    layer.Transceivers(idx_38).Regions(idx_school_38).Tag='UNC';
    layer.Transceivers(idx_120).Regions(idx_school_120).Tag='UNC';
end
