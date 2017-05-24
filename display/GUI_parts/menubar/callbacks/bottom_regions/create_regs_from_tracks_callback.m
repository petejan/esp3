function create_regs_from_tracks_callback(~,~,type,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);

if found==0
    return;
end

trans_obj=layer.Transceivers(idx_freq);
trans_obj.create_track_regs('Type',type);

display_tracks(main_figure);
update_regions_tab(main_figure);
update_reglist_tab(main_figure,[],0);
display_regions(main_figure,'both');
order_stacks_fig(main_figure);



