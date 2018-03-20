function save_echo(main_figure,path_echo,fileN)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
[trans_obj,~]=layer.get_trans(curr_disp);

axes_panel_comp=getappdata(main_figure,'Axes_panel');
main_axes=axes_panel_comp.main_axes;
haxes=axes_panel_comp.haxes;
vaxes=axes_panel_comp.vaxes;

new_fig=new_echo_figure(main_figure,'Units','Pixels','Position',get(0,'ScreenSize'),...
    'Name','','Tag','save_echo');
pos=get(new_fig,'position');
set(new_fig,'Alphamap',main_figure.Alphamap);
new_axes=copyobj(main_axes,new_fig);
set(new_axes,'units','pixels','XAxisLocation','bottom','XTickLabelRotation',90,'outerposition',[0 0 pos(3) pos(4)],'YTickLabel',vaxes.YTickLabel,'XTickLabel',haxes.XTickLabel);
set(new_fig,'Visible','off');

text_obj=findobj(new_fig,'-property','Fontsize');
set(text_obj,'Fontsize',16);

line_obj=findobj(new_fig,'Type','Line');
set(line_obj,'Linewidth',2);
layers_Str=list_layers(layer,'nb_char',80);
title(new_axes,sprintf('%s : %s',deblank(trans_obj.Config.ChannelID),layers_Str{1}),'interpreter','none');
colorbar(new_axes);

switch fileN
    case '-clipboard'
         print(new_fig,'-clipboard','-dbitmap');
         %hgexport(new_fig,'-clipboard');
    otherwise
        if isempty(path_echo)
            [path_echo,~,~]=fileparts(layer.Filename{1});
        end
        
        if isempty(fileN)
            fileN=[layers_Str{1} '.png'];
        end
        
        print(new_fig,fullfile(path_echo,fileN),'-dpng','-r300');
end
close(new_fig);

end