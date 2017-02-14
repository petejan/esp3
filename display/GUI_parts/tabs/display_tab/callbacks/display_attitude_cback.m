
function display_attitude_cback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer.AttitudeNav)
    warning('No attitude');
    return;
end

layers_Str=list_layers(layer);
new_figs=layer.AttitudeNav.display_att();
for i=1:length(new_figs)
    new_echo_figure(main_figure,'fig_handle',new_figs(i),'Tag',sprintf('attitude%.0f',layer.ID_num),'Name',sprintf('Attitude  %s',layers_Str{1}));
end

end