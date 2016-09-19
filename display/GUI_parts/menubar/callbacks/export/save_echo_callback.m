function save_echo_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
axes_panel_comp=getappdata(main_figure,'Axes_panel');
main_axes=axes_panel_comp.main_axes;
haxes=axes_panel_comp.haxes;
vaxes=axes_panel_comp.vaxes;

new_fig=figure('visible','off','menubar','none','position',get(0,'ScreenSize'),'Color','w',...                                     
    'Name','',...
    'NumberTitle','off');
new_axes=copyobj(main_axes,new_fig);
set(new_axes,'units','pixels','XAxisLocation','bottom','XTickLabelRotation',90);
set(new_axes,'outerposition',get(new_fig,'position'));
set(new_axes,'XTickLabel',haxes.XTickLabel);
set(new_axes,'YTickLabel',vaxes.YTickLabel);

text_obj=findobj(new_fig,'-property','Fontsize');
set(text_obj,'Fontsize',16);

line_obj=findobj(new_fig,'Type','Line');
set(line_obj,'Linewidth',2);
layers_Str=list_layers(layer,'nb_char',80);
title(new_axes,sprintf('%s',layers_Str{1}));
colorbar();

[path_tmp,~,~]=fileparts(layer.Filename{1});
[file_n,path_tmp] = uiputfile(fullfile(path_tmp,[layers_Str{1} '.png']),'Save file name');

if isequal(file_n,0) || isequal(path,0)
    close(new_fig);
    return;
else
   print(new_fig,fullfile(path_tmp,file_n),'-dpng','-r300');
    close(new_fig);
end


end