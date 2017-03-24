function toggle_func(src, ~,main_figure)
%cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
%curr_disp=getappdata(main_figure,'Curr_disp');
reset_disp_info(main_figure);
ah=axes_panel_comp.main_axes;
axes(ah);

type=src.Tag;
childs=findall(main_figure,'type','uitoggletool');
for i=1:length(childs)
    if ~strcmp(get(childs(i),'tag'),type)
        set(childs(i),'state','off');
    end
end
initialize_interactions(main_figure,0);
region_tab_comp=getappdata(main_figure,'Region_tab');
set(region_tab_comp.create_button,'value',get(region_tab_comp.create_button,'Min'));

if isa(src,'matlab.ui.container.toolbar.PushTool')
    return;
end

switch src.State
    case'on'
        iptPointerManager(main_figure,'disable');
        axes_panel_comp.bad_transmits.UIContextMenu=[];
        axes_panel_comp.bottom_plot.UIContextMenu=[];
        switch type
            case 'zin'
                setptr(main_figure,'glassplus');
                set(main_figure,'WindowButtonDownFcn',{@zoom_in_callback,main_figure});
            case 'zout'
                setptr(main_figure,'glassminus');
                set(main_figure,'WindowButtonDownFcn',{@zoom_out_callback,main_figure});
            case 'bt'
                set(main_figure,'Pointer','arrow');
                set(main_figure,'WindowButtonDownFcn',@(src,envdata)mark_bad_transmit(src,envdata,main_figure));
            case 'ed_bot'
                set(main_figure,'Pointer','crosshair');
                set(main_figure,'WindowButtonDownFcn',@(src,envdata)edit_bottom(src,envdata,main_figure));
            case 'loc'
                set(main_figure,'Pointer','arrow');
                set(main_figure,'WindowButtonDownFcn',@(src,envdata)disp_loc(src,envdata,main_figure));
            case 'meas'
                set(main_figure,'Pointer','cross');
                set(main_figure,'WindowButtonDownFcn',@(src,envdata)measure_distance(src,envdata,main_figure));
            case 'create_reg'
                set(main_figure,'Pointer','cross');
                set(main_figure,'WindowButtonDownFcn',@create_region);
            otherwise 
                set(main_figure,'Pointer','arrow');
                set(main_figure,'WindowButtonDownFcn',@(src,envdata)select_area_cback(src,envdata,main_figure));
                 
        end
    case 'off'
        reset_mode(0,0,main_figure);
end

end
