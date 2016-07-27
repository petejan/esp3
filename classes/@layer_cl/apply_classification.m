function h_figs=apply_classification(layer,idx_freq,idx_schools,disp_level)

[idx_38,found_38]=find_freq_idx(layer,38000);
[idx_18,found_18]=find_freq_idx(layer,18000);
[idx_120,found_120]=find_freq_idx(layer,120000);

if ~found_18||~found_120||~found_38
    warning('Cannot find every frequencies! Cannot apply classification here....');
    h_figs=[];
    return;
end

for idx_school=idx_schools
    
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
    
    output_reg_38=school_38_reg.integrate_region(layer.Transceivers(idx_38),'denoised',0);
    output_reg_18=school_18_reg.integrate_region(layer.Transceivers(idx_18),'denoised',0);
    output_reg_120=school_120_reg.integrate_region(layer.Transceivers(idx_120),'denoised',1);
    
    delta_120_18=pow2db_perso(output_reg_120.Sv_mean_lin)-pow2db_perso(output_reg_18.Sv_mean_lin);
    delta_120_38=pow2db_perso(output_reg_120.Sv_mean_lin)-pow2db_perso(output_reg_38.Sv_mean_lin);
    
    
    if disp_level>0
        h_figs=figure('Name',sprintf('School %d',idx_school_38),'NumberTitle','off','tag','classif');
        ax1=subplot(2,1,1);
        pcolor(output_reg_120.x_node,output_reg_120.Range_mean,delta_120_38);
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
        pcolor(output_reg_120.x_node,output_reg_120.Range_mean,delta_120_18);
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
    end
    
    school_struct.nb_cell=length(~isnan(delta_120_18(:)));
    school_struct.delta_sv_120_18_mean=nanmean(delta_120_18(:));
    school_struct.delta_sv_120_38_mean=nanmean(delta_120_38(:));
    school_struct.aggregation_depth_mean=nanmean(output_reg_38.Range_mean(:));
    school_struct.aggregation_depth_min=nanmax(output_reg_38.Range_mean(:));
    school_struct.bottom_depth=nanmean(layer.Transceivers(idx_18).Bottom.Range);
    school_struct.lat_mean=nanmean(output_reg_38.Lat_E(:));
    
    
    class_tree_obj=decision_tree_cl(fullfile(whereisEcho,'classification.xml'));
    tag=class_tree_obj.apply_classification_tree(school_struct);
    
    layer.Transceivers(idx_18).Regions(idx_school_18).Tag=tag;
    layer.Transceivers(idx_38).Regions(idx_school_38).Tag=tag;
    layer.Transceivers(idx_120).Regions(idx_school_120).Tag=tag;
end

