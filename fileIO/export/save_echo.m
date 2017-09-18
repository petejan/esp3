function save_echo(main_figure,path_echo,fileN)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

axes_panel_comp=getappdata(main_figure,'Axes_panel');
main_axes=axes_panel_comp.main_axes;
haxes=axes_panel_comp.haxes;
vaxes=axes_panel_comp.vaxes;

new_fig=new_echo_figure(main_figure,'Units','Pixels','Position',get(0,'ScreenSize'),...
    'Name','','Tag','save_echo');
new_axes=copyobj(main_axes,new_fig);
set(new_axes,'units','pixels','XAxisLocation','bottom','XTickLabelRotation',90);
set(new_axes,'outerposition',get(new_fig,'position'));
set(new_axes,'XTickLabel',haxes.XTickLabel);
set(new_axes,'YTickLabel',vaxes.YTickLabel);
set(new_fig,'Visible','off');

text_obj=findobj(new_fig,'-property','Fontsize');
set(text_obj,'Fontsize',16);

line_obj=findobj(new_fig,'Type','Line');
set(line_obj,'Linewidth',2);
layers_Str=list_layers(layer,'nb_char',80);
title(new_axes,sprintf('%s',layers_Str{1}),'interpreter','none');
colorbar();

if isempty(path_echo)
    [path_echo,~,~]=fileparts(layer.Filename{1});
end

if isempty(fileN)
    fileN=[layers_Str{1} '.png'];
end

print(new_fig,fullfile(path_echo,fileN),'-dpng','-r300');
close(new_fig);



end