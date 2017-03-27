function merge_overlapping_regions_per_tag_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
if ~isempty(layer.Transceivers(idx_freq).Regions)
    new_regions=[];
    tag=layer.Transceivers(idx_freq).get_tags();
    for t=1:1:length(tag)
        idx=layer.Transceivers(idx_freq).list_regions_tag(tag{t});
        regions_tmps=layer.Transceivers(idx_freq).Regions(idx).merge_regions();
        for i=1:length(regions_tmps)
            regions_tmps(i).Tag=tag{t};
        end
        new_regions=[new_regions regions_tmps];
    end
    layer.Transceivers(idx_freq).rm_all_region();
    layer.Transceivers(idx_freq).add_region(new_regions,'IDs',1:length(new_regions));
    display_regions(main_figure,'both');
    update_regions_tab(main_figure,[]);
    order_stacks_fig(main_figure);
    update_reglist_tab(main_figure,[],0);
end

end