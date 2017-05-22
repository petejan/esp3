function undock_mini_axes_callback(src,~,main_figure,dest)

layer=getappdata(main_figure,'Layer');
if isempty(layer);
    return;
end

mini_axes_comp=getappdata(main_figure,'Mini_axes');

switch dest
    case 'main_figure'
        pos_out=[0 0 0.85 0.55];
        disp_tab_comp=getappdata(main_figure,'Display_tab');
        parent=disp_tab_comp.display_tab;
        mini_axes_comp=getappdata(main_figure,'Mini_axes');
        delete(mini_axes_comp.mini_ax.Parent); 
    otherwise
        
        size_max = get(0, 'MonitorPositions');
        pos_fig=[size_max(1,1) size_max(1,2)+size_max(1,4)*0.2 size_max(1,3) size_max(1,4)*0.5];
        pos_out=[0 0 1 1];
        parent=new_echo_figure(main_figure,...
            'Units','pixels',...
            'Position',pos_fig,...
            'Name','Overview',...   
            'Resize','on',...
            'CloseRequestFcn',@close_min_axis,...
            'Tag','mini_ax');
        iptPointerManager(parent);
        delete(mini_axes_comp.mini_ax);
        initialize_interactions_mini_ax(parent,main_figure);
end

load_mini_axes(main_figure,parent,pos_out);
update_mini_ax(main_figure,1);
display_regions(main_figure,'mini');
update_cmap(main_figure);
reverse_y_axis(main_figure);
display_bottom(main_figure);

end