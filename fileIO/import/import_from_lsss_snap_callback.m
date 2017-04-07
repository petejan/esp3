function import_from_lsss_snap_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
[path_f,~,~]=fileparts(layer.Filename{1});

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.snap')}, 'Pick a .snap','MultiSelect','off');
if isempty(Filename)||isnumeric(Filename)
    return;
end

layer.Transceivers(idx_freq).set_bot_reg_from_lsss_snap(fullfile(PathToFile,Filename),idx_freq);


setappdata(main_figure,'Layer',layer);
display_bottom(main_figure);

update_regions_tab(main_figure,1);
update_reglist_tab(main_figure,[],0);
display_regions(main_figure,'both');

set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
order_stacks_fig(main_figure);


end