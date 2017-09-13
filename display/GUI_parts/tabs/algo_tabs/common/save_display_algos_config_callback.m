
function save_display_algos_config_callback(~,~,main_fig)
curr_disp=getappdata(main_fig,'Curr_disp');
app_path=getappdata(main_fig,'App_path');
layer=getappdata(main_fig,'Layer');
if isempty(layer)
    return;
end
update_algos(main_fig);
idx_freq=find_freq_idx(layer,curr_disp.Freq);
write_config_to_xml(app_path,curr_disp,layer.Transceivers(idx_freq).Algo);
end