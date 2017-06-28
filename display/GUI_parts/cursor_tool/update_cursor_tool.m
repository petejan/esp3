function update_cursor_tool(main_figure)
cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
app_path_main=whereisEcho();
if isempty(cursor_mode_tool_comp)
    return;
end

jToolbar = get(get(cursor_mode_tool_comp.cursor_mode_tool,'JavaContainer'),'ComponentPeer');
jedit = get(cursor_mode_tool_comp.edit_bottom,'JavaContainer');
jMenu = get(jedit,'MenuComponent');
jMenu.removeAll;

jActionItem1 = jMenu.add('Classic Tool');
jActionItem1.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','edit_bot.png')));
set(jActionItem1, 'ActionPerformedCallback',{@update_tag, main_figure,'ed_bot','Edit Bottom (3)'});

jActionItem2 = jMenu.add('Spline Tool');
jActionItem2.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','edit_bot_spline.png')));
set(jActionItem2, 'ActionPerformedCallback',{@update_tag, main_figure,'ed_bot_spline','Edit Bottom (spline) (3)'});

jActionItem3 = jMenu.add('Brush Tool');
jActionItem3.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','brush.png')));
set(jActionItem3, 'ActionPerformedCallback',{@update_tag, main_figure,'brush_soundings','Brush Soundings (3)'});


jToolbar.revalidate;

end

function update_tag(src,~,main_figure,new_tag,new_string)
cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
if isempty(cursor_mode_tool_comp)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
app_path_main=whereisEcho();
icon=get_icons_cdata(fullfile(app_path_main,'icons'));

switch new_tag
    case 'ed_bot'      
        set(cursor_mode_tool_comp.edit_bottom,'Cdata',icon.edit_bot);
    case 'ed_bot_spline'
        set(cursor_mode_tool_comp.edit_bottom,'Cdata',icon.edit_bot_spline);
    case 'brush_soundings'
        set(cursor_mode_tool_comp.edit_bottom,'Cdata',icon.brush);
end

set(cursor_mode_tool_comp.edit_bottom,'tag',new_tag,'TooltipString',new_string);
curr_disp.CursorMode=curr_disp.CursorMode;

end
 