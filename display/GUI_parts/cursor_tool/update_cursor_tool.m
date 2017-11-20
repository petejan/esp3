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
set(jActionItem1, 'ActionPerformedCallback',{@update_ed_bot_tag, main_figure,'ed_bot','Edit Bottom (3)'});

jActionItem2 = jMenu.add('Spline Tool');
jActionItem2.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','edit_bot_spline.png')));
set(jActionItem2, 'ActionPerformedCallback',{@update_ed_bot_tag, main_figure,'ed_bot_spline','Edit Bottom (spline) (3)'});

jActionItem3 = jMenu.add('Erase Tool');
jActionItem3.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','eraser.png')));
set(jActionItem3, 'ActionPerformedCallback',{@update_ed_bot_tag, main_figure,'erase_soundings','Erase Soundings (3)'});

jActionItem3 = jMenu.add('Brush Tool');
jActionItem3.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','brush.png')));
set(jActionItem3, 'ActionPerformedCallback',{@update_ed_bot_tag, main_figure,'ed_bot_sup','Brush Bottom (3)'});

jedit_reg = get(cursor_mode_tool_comp.create_reg,'JavaContainer');
jMenu_reg = get(jedit_reg,'MenuComponent');
jMenu_reg.removeAll;

jActionItem1 = jMenu_reg.add('Rectangular');
jActionItem1.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','create_reg_rect.png')));
set(jActionItem1, 'ActionPerformedCallback',{@update_create_region_tag, main_figure,'create_reg_rect','Create Rectangular region (3)'});

jActionItem2 = jMenu_reg.add('Horizontal');
jActionItem2.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','create_reg_horz.png')));
set(jActionItem2, 'ActionPerformedCallback',{@update_create_region_tag, main_figure,'create_reg_horz','Create Horizontal region (3)'});

jActionItem3 = jMenu_reg.add('Vertical');
jActionItem3.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','create_reg_vert.png')));
set(jActionItem3, 'ActionPerformedCallback',{@update_create_region_tag, main_figure,'create_reg_vert','Create Vertical region (3)'});

jActionItem3 = jMenu_reg.add('Polygon');
jActionItem3.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','create_reg_poly.png')));
set(jActionItem3, 'ActionPerformedCallback',{@update_create_region_tag, main_figure,'create_reg_poly','Create Polygon region (3)'});

jActionItem4 = jMenu_reg.add('Hand Drawn');
jActionItem4.setIcon(javax.swing.ImageIcon(fullfile(app_path_main,'icons','create_reg_hd.png')));
set(jActionItem4, 'ActionPerformedCallback',{@update_create_region_tag, main_figure,'create_reg_hd','Create Hand Drawn region (3)'});


jToolbar.revalidate;

end

function update_ed_bot_tag(src,~,main_figure,new_tag,new_string)
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
    case 'erase_soundings'
        set(cursor_mode_tool_comp.edit_bottom,'Cdata',icon.eraser);
    case 'ed_bot_sup'
        set(cursor_mode_tool_comp.edit_bottom,'Cdata',icon.brush);        
end

set(cursor_mode_tool_comp.edit_bottom,'tag',new_tag,'TooltipString',new_string,'State','on');


curr_disp.CursorMode='Edit Bottom';

end
 



function update_create_region_tag(src,~,main_figure,new_tag,new_string)
cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
if isempty(cursor_mode_tool_comp)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
app_path_main=whereisEcho();
icon=get_icons_cdata(fullfile(app_path_main,'icons'));

switch new_tag
    case 'create_reg_rect'
        set(cursor_mode_tool_comp.create_reg,'Cdata',icon.create_reg_rect);
    case 'create_reg_horz'
        set(cursor_mode_tool_comp.create_reg,'Cdata',icon.create_reg_horz);
    case 'create_reg_vert'
        set(cursor_mode_tool_comp.create_reg,'Cdata',icon.create_reg_vert);
    case 'create_reg_poly'
        set(cursor_mode_tool_comp.create_reg,'Cdata',icon.create_reg_poly);
    case 'create_reg_hd'
        set(cursor_mode_tool_comp.create_reg,'Cdata',icon.create_reg_hd);
end

set(cursor_mode_tool_comp.create_reg,'tag',new_tag,'TooltipString',new_string,'State','on');

curr_disp.CursorMode='Create Region';

end
 
