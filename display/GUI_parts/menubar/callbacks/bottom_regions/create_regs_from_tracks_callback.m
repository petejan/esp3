function create_regs_from_tracks_callback(~,~,type,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
if isempty(trans_obj)
    return;
end

trans_obj.create_track_regs('Type',type);

display_tracks(main_figure);
update_reglist_tab(main_figure,[]);
display_regions(main_figure,'both');
order_stacks_fig(main_figure);



