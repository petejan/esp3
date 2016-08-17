function merge_overlapping_regions_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
if ~isempty(layer.Transceivers(idx_freq).Regions)
    new_regions=layer.Transceivers(idx_freq).Regions.merge_regions();
    layer.Transceivers(idx_freq).rm_all_region();
    layer.Transceivers(idx_freq).add_region(new_regions,'IDs',1:length(new_regions));
    display_regions(main_figure);
    update_regions_tab(main_figure,[]);
    order_stacks_fig(main_figure);
end

end