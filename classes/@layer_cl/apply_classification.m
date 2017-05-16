function h_figs=apply_classification(layer,idx_freq,idx_schools,disp_level)
disp('Applying classification');
[idx_38,found_38]=find_freq_idx(layer,38000);
%[idx_18,found_18]=find_freq_idx(layer,18000);
[idx_120,found_120]=find_freq_idx(layer,120000);
% 
% if ~found_18||~found_120||~found_38
%     warning('Cannot find every frequencies! Cannot apply classification here....');
%     h_figs=[];
%     return;
% end

if ~found_120||~found_38
    warning('Cannot find every frequencies! Cannot apply classification here....');
    h_figs=[];
    return;
end

school_regs=layer.Transceivers(idx_freq).Regions(idx_schools);
layer.copy_region_across(idx_freq,school_regs,[idx_38,idx_120]);

for idx_school=idx_schools
    
    school_reg=layer.Transceivers(idx_freq).Regions(idx_school);
    
    %[idx_school_18,found_18]=layer.Transceivers(idx_18).find_reg_idx(school_reg.Unique_ID);
    [idx_school_38,found_38]=layer.Transceivers(idx_38).find_reg_idx(school_reg.Unique_ID);
    [idx_school_120,found_120]=layer.Transceivers(idx_120).find_reg_idx(school_reg.Unique_ID);
    
    %if ~found_18||~found_120||~found_38
    if ~found_120||~found_38
        warning('Cannot find school on every frequency!Pass...');
        h_figs=[];
        return;
    end
    
%     if length(idx_school_18)>1||length(idx_school_38)>1||length(idx_school_120)>1
%          warning('Several regions with similar ID/Name combination on one frequency...');
%         h_figs=[];
%         return;
%     end
%     
    if length(idx_school_38)>1||length(idx_school_120)>1
         warning('Several regions with similar ID/Name combination on one frequency...');
        h_figs=[];
        return;
    end

    
    %school_18_reg=layer.Transceivers(idx_18).Regions(idx_school_18(1));
    school_38_reg=layer.Transceivers(idx_38).Regions(idx_school_38(1));
    school_120_reg=layer.Transceivers(idx_120).Regions(idx_school_120(1));
    
    output_reg_38=layer.Transceivers(idx_38).integrate_region_v2(school_38_reg,'denoised',0);
    %output_reg_18= layer.Transceivers(idx_18).integrate_region_v2(school_18_reg,'denoised',0);
    output_reg_120= layer.Transceivers(idx_120).integrate_region_v2(school_120_reg,'denoised',1);
    
    %delta_120_18_cell=pow2db_perso(output_reg_120.Sv_mean_lin)-pow2db_perso(output_reg_18.Sv_mean_lin);
    delta_120_38_cell=pow2db_perso(output_reg_120.Sv_mean_lin)-pow2db_perso(output_reg_38.Sv_mean_lin);
    
    %delta_120_18=pow2db_perso(nanmean(output_reg_120.Sv_mean_lin(:)))-pow2db_perso(nanmean(output_reg_18.Sv_mean_lin(:)));
    delta_120_38=pow2db_perso(nanmean(output_reg_120.Sv_mean_lin(:)))-pow2db_perso(nanmean(output_reg_38.Sv_mean_lin(:)));
    
    
    if disp_level>0&&nansum(output_reg_120.Range_mean(:))>0
       
        h_figs=new_echo_figure([],'Name',sprintf('School %d',idx_school_38),'Tag','classif');
        ax1=axes(h_fig);
        pcolor(ax1,(output_reg_120.Dist_E+output_reg_120.Dist_S)/2,output_reg_120.Range_mean,delta_120_38_cell);
        colormap(jet);
        grid on;
        xlabel('Distance(m)')
        ylabel('Depth(m)')
        hold on;
        axis ij;
        caxis([-10 10]);
        colorbar;
        title(sprintf('\\Delta 120-38 dB difference of school %.0f',idx_school_38));
        

    else
        h_figs=[];
    end
    
    school_struct.nb_cell=length(~isnan(output_reg_120.Sv_mean_lin(:)));
    %school_struct.delta_sv_120_18_mean=delta_120_18;
    school_struct.delta_sv_120_38_mean=delta_120_38;
    school_struct.aggregation_depth_mean=nanmean(output_reg_38.Range_mean(:));
    school_struct.aggregation_depth_min=nanmax(output_reg_38.Range_mean(:));
    %school_struct.bottom_depth=nanmean(layer.Transceivers(idx_18).get_bottom_range());
    school_struct.lat_mean=nanmean(output_reg_38.Lat_E(:));
    
    class_tree_obj=decision_tree_cl(fullfile(whereisEcho,'config','classification.xml'));
    tag=class_tree_obj.apply_classification_tree(school_struct);
    
    %layer.Transceivers(idx_18).Regions(idx_school_18).Tag=tag;
    layer.Transceivers(idx_38).Regions(idx_school_38).Tag=tag;
    layer.Transceivers(idx_120).Regions(idx_school_120).Tag=tag;
    
end
    
