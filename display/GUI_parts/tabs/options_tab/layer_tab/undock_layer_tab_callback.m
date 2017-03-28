function undock_layer_tab_callback(~,~,main_figure,dest)

layer=getappdata(main_figure,'Layer');
if isempty(layer);
    return;
end
layer_tab_comp=getappdata(main_figure,'Layer_tab');

switch dest
    case 'main_figure'
        delete(layer_tab_comp.layer_tab);
        dest_fig=getappdata(main_figure,'option_tab_panel');
    otherwise
        delete(layer_tab_comp.layer_tab);
        size_max = get(0, 'MonitorPositions');
        pos_fig=[size_max(1,1)+size_max(1,3)*0.3 size_max(1,2)+size_max(1,4)*0.4 size_max(1,3)*0.4 size_max(1,4)*0.2];
        dest_fig=new_echo_figure(main_figure,...
            'Units','pixels',...
            'Position',pos_fig,...
            'Name','Layers',...
            'Resize','on',...
            'CloseRequestFcn',@close_layer_tab,...
            'Tag','layer_tab');
end

 load_layer_tab(main_figure,dest_fig);

end

function close_layer_tab(src,~,main_figure)
undock_layer_tab_callback(src,[],main_figure,'main_figure');
end