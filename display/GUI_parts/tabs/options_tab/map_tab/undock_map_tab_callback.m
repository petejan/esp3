function undock_map_tab_callback(~,~,main_figure,dest)

layer=getappdata(main_figure,'Layer');
if isempty(layer);
    return;
end
map_tab_comp=getappdata(main_figure,'Map_tab');

switch dest
    case 'main_figure'
        delete(map_tab_comp.map_tab);
        dest_fig=getappdata(main_figure,'option_tab_panel');
    otherwise
        delete(map_tab_comp.map_tab);
        size_max = get(0, 'MonitorPositions');
        pos_fig=[size_max(1,1)+size_max(1,3)*0.3 size_max(1,2)+size_max(1,4)*0.4 size_max(1,3)*0.4 size_max(1,4)*0.2];
        dest_fig=new_echo_figure(main_figure,...
            'Units','pixels',...
            'Position',pos_fig,...
            'Name','Navigation',...
            'Resize','on',...
            'CloseRequestFcn',@close_Map_tab,...
            'Tag','Map_tab');
end

 load_map_tab(main_figure,dest_fig);

end

function close_Map_tab(src,~,main_figure)
delete(src);
dest_fig=getappdata(main_figure,'option_tab_panel');
load_map_tab(main_figure,dest_fig);
end