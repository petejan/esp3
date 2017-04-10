
function prepare_classification(layer,idx_to_process,reprocess,own)


[idx_38,found_38]=find_freq_idx(layer,38000);
[idx_120,found_120]=find_freq_idx(layer,120000);

if ~found_38||~found_120
    warning('Cannot find 38 kHz!Pass...');
    return;
end


for uu=idx_to_process
 
    if (reprocess==1||isempty(get_datamat(layer.Transceivers(uu).Data,'svdenoised')))&&uu==idx_120
        layer.Transceivers(uu).apply_algo('Denoise');     
    end
    
    if reprocess==1
        layer.Transceivers(uu).apply_algo('BadPings');           
    end
    
    if uu==idx_38
        if reprocess==1  
            layer.Transceivers(uu).rm_region_name('School');
            if own==0
            layer.Transceivers(uu).add_algo(algo_cl('Name','SchoolDetection','Varargin',struct(...
                'Type','svdenoised',...
                'Sv_thr',-70,...
                'l_min_can',25,...
                'h_min_tot',10,...
                'h_min_can',5,...
                'l_min_tot',25,...
                'nb_min_sples',100,...
                'horz_link_max',55,...
                'vert_link_max',5)));  
            end
            
            layer.Transceivers(uu).apply_algo('SchoolDetection');
        end
    elseif uu==idx_120
        layer.Transceivers(uu).rm_region_name('School');
        if own==0
            layer.Transceivers(uu).add_algo(algo_cl('Name','SchoolDetection','Varargin',struct(...
                'Type','svdenoised',...
                'Sv_thr',-70,...
                'l_min_can',5,...
                'h_min_tot',5,...
                'h_min_can',5,...
                'l_min_tot',5,...
                'nb_min_sples',100,...
                'horz_link_max',55,...
                'vert_link_max',5,...
                'depth_max',400)));
        end
        layer.Transceivers(uu).apply_algo('SchoolDetection');
    else
        layer.Transceivers(uu).rm_region_name('School');
    end

end
idx_school_120 = layer.Transceivers(idx_120).find_regions_name('School');

if ~isempty(idx_school_120)
    layer.copy_region_across(idx_120,layer.Transceivers(idx_120).Regions(idx_school_120),idx_38);
    layer.Transceivers(idx_120).rm_region_name('School');
    new_regions=layer.Transceivers(idx_38).Regions.merge_regions();
    layer.Transceivers(idx_38).rm_all_region();
    layer.Transceivers(idx_38).add_region(new_regions);
end

