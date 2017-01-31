function listenCursorMode(src,listdata,main_figure)
%disp('ListenCursorMode')
cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
info_panel_comp=getappdata(main_figure,'Info_panel');
cur_str=sprintf('Cursor mode: %s',listdata.AffectedObject.CursorMode);
set(info_panel_comp.cursor_mode,'String',cur_str);


switch listdata.AffectedObject.CursorMode
    case 'Zoom In'
        toggle_func(cursor_mode_tool_comp.zoom_in,[],main_figure);
    case 'Zoom Out'
        toggle_func(cursor_mode_tool_comp.zoom_out,[],main_figure);
    case 'Bad Transmits'
        toggle_func(cursor_mode_tool_comp.bad_trans,[],main_figure);
    case 'Edit Bottom'
        toggle_func(cursor_mode_tool_comp.edit_bottom,[],main_figure);
    case 'Measure'
        toggle_func(cursor_mode_tool_comp.measure,[],main_figure);
    case 'Create Region'
        reset_mode(0,0,main_figure);
        iptPointerManager(main_figure,'disable');
        set(main_figure,'Pointer','cross');
        set(main_figure,'WindowButtonDownFcn',@create_region);      
    case 'Normal'

        reset_mode(0,0,main_figure);
        set_alpha_map(main_figure);
end
order_axes(main_figure);
end