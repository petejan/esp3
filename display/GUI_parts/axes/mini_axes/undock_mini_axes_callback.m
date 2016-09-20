function undock_mini_axes_callback(src,~,main_figure)

layer=getappdata(main_figure,'Layer');
if isempty(layer);
    return;
end

mini_axes_comp=getappdata(main_figure,'Mini_axes');

switch class(src)
    case 'matlab.ui.Figure'
        pos_out=[0 0 0.85 0.55];
        disp_tab_comp=getappdata(main_figure,'Display_tab');
        parent=disp_tab_comp.display_tab;
    case {'matlab.ui.control.UIControl','matlab.graphics.axis.Axes'}
        
        switch class(mini_axes_comp.mini_ax.Parent)
            case 'matlab.ui.container.Tab'
                delete(mini_axes_comp.mini_ax);
                size_max = get(0, 'MonitorPositions');
                pos_fig=[size_max(1,1) size_max(1,2)+size_max(1,4)*0.2 size_max(1,3) size_max(1,4)*0.5];
                pos_out=[0 0 1 1];
                parent=figure('units','pixels','position',pos_fig,...
                    'Color','White',...
                    'Name','Overview',...
                    'NumberTitle','off',...
                    'Resize','on',...
                    'MenuBar','none',...
                    'DockControls','off',...
                    'CloseRequestFcn',{@close_min_axis,main_figure},...
                    'WindowScrollWheelFcn',{@scroll_fcn_callback,main_figure},...
                    'KeyPressFcn',{@keyboard_func,main_figure});
                hfigs=getappdata(main_figure,'ExternalFigures');
                setappdata(main_figure,'ExternalFigures',[parent hfigs]); 
            case 'matlab.ui.Figure'
                delete(mini_axes_comp.mini_ax.Parent);
                pos_out=[0 0 0.85 0.55];
                disp_tab_comp=getappdata(main_figure,'Display_tab');
                parent=disp_tab_comp.display_tab; 
        end
end
delete(src);
load_mini_axes(main_figure,parent,pos_out);
update_mini_ax(main_figure,1);
display_regions(main_figure,'mini');
update_cmap(main_figure);
reverse_y_axis(main_figure);
display_bottom(main_figure);

end