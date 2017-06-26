function load_cursor_tool(main_figure)

if ~isdeployed
    disp('Loading Toolbar');
end

cursor_mode_tool_comp.cursor_mode_tool=uitoolbar(main_figure,'Tag','toolbar_esp3');
app_path_main=whereisEcho();
icon=get_icons_cdata(fullfile(app_path_main,'icons'));


cursor_mode_tool_comp.zoom_in=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.zin,'TooltipString','Zoom In (1)','Tag','zin');
cursor_mode_tool_comp.zoom_out=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.zout,'TooltipString','Zoom Out (shift+1)','Tag','zout');
cursor_mode_tool_comp.bad_trans=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.bad_trans ,'TooltipString','Bad Transmit (2)','Tag','bt');
cursor_mode_tool_comp.edit_bottom=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.edit_bot ,'TooltipString','Edit Bottom (3)','Tag','ed_bot');
cursor_mode_tool_comp.create_reg=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.create_reg ,'TooltipString','Create Region (4)','Tag','create_reg');
cursor_mode_tool_comp.measure=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.ruler ,'TooltipString','Measure Distance (5)','Tag','meas');
cursor_mode_tool_comp.measure=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.brush ,'TooltipString','Brush Soundings (6)','Tag','brush_soundings');

childs=findall(main_figure,'type','uitoggletool');
set(childs,...
    'ClickedCallback',{@set_curr_disp_mode,main_figure});

cursor_mode_tool_comp.undo = uipushtool('parent',cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.undo,'TooltipString','Undo','Tag','undo''parent','ClickedCallback','uiundo(gcbf,''execUndo'')','Separator','on');
cursor_mode_tool_comp.redo = uipushtool('parent',cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.redo,'TooltipString','Redo','Tag','redo','ClickedCallback','uiundo(gcbf,''execRedo'')');

cursor_mode_tool_comp.previous=uipushtool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.prev_lay ,'TooltipString','Previous Layer (p)','ClickedCallback',{@change_layer_callback,main_figure,'prev'},'Separator','on');
cursor_mode_tool_comp.next=uipushtool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.next_lay ,'TooltipString','Next Layer (n)','ClickedCallback',{@change_layer_callback,main_figure,'next'});
cursor_mode_tool_comp.del=uipushtool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.del_lay ,'TooltipString','Delete Layer','ClickedCallback',{@delete_layer_callback,main_figure});


setappdata(main_figure,'Cursor_mode_tool',cursor_mode_tool_comp);
end


function set_curr_disp_mode(src,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');

if strcmp(src.State,'on')
    switch src.Tag
        case 'bt'
            curr_disp.CursorMode='Bad Transmits';
        case 'zout'
            curr_disp.CursorMode='Zoom Out';
        case 'zin'
            curr_disp.CursorMode='Zoom In';
        case 'ed_bot'
            curr_disp.CursorMode='Edit Bottom';
        case 'meas'
            curr_disp.CursorMode='Measure';
        case 'create_reg'
            curr_disp.CursorMode='Create Region';
        case 'brush_soundings'
            curr_disp.CursorMode='Brush Soundings';
    end
else
    curr_disp.CursorMode='Normal';
end
setappdata(main_figure,'Curr_disp',curr_disp);


end









