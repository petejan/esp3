
function display_attitude_cback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);

layers_Str=list_layers(layer);
new_figs=layer.Transceivers(idx_freq).AttitudeNavPing.display_att(main_figure);
for i=1:length(new_figs)
    new_echo_figure(main_figure,'fig_handle',new_figs(i),'Tag',sprintf('attitude%.0f',layer.ID_num),'Name',sprintf('Attitude  %s',layers_Str{1}));
end

end