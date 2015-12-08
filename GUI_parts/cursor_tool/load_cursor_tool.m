function load_cursor_tool(main_figure)

app_path=getappdata(main_figure,'App_path');
%curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
layers=getappdata(main_figure,'Layers');

nb_layers=length(layers);
layers_Str=list_layers(layers);


if isappdata(main_figure,'Cursor_mode_tool')
    cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');  
    [idx,~]=find_layer_idx(layers,layer.ID_num);
    cursor_mode_tool_comp.jCombo.removeAllItems();
    for i=1:nb_layers
         cursor_mode_tool_comp.jCombo.addItem(layers_Str{i});
    end
    set(cursor_mode_tool_comp.jCombo, 'SelectedIndex', idx-1);
else
    
    %idx_freq=find_freq_idx(layer,curr_disp.Freq);
    
    
    
    cursor_mode_tool_comp.cursor_mode_tool=uitoolbar(main_figure);
    
    if isdeployed
        icon=get_icons_cdata([]);
    else
        icon=get_icons_cdata(fullfile(app_path.main,'icons'));
    end
    
    cursor_mode_tool_comp.zoom_in=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.zin,'TooltipString','Zoom +','Tag','zin');
    cursor_mode_tool_comp.zoom_out=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.zout,'TooltipString','Zoom -','Tag','zout');
    cursor_mode_tool_comp.pan=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.pan ,'TooltipString','Pan','Tag','pan');
    cursor_mode_tool_comp.edit_bottom=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.edit_bot ,'TooltipString','Edit Bottom','Tag','ed_bot');
    cursor_mode_tool_comp.bad_trans=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.bad_trans ,'TooltipString','Bad Transmit','Tag','bt');
    

    childs=findall(main_figure,'type','uitoggletool');
    set(childs,...
        'ClickedCallback',{@set_curr_disp_mode,main_figure});
    
    [idx,~]=find_layer_idx(layers,layer.ID_num);
    
    %jToolbar = get(get(cursor_mode_tool_comp.cursor_mode_tool,'JavaContainer'),'ComponentPeer');
    jToolbar = findjobj(main_figure,'-nomenu','class','mjtoolbar');
    
    if ~isempty(jToolbar)
        cursor_mode_tool_comp.jCombo = javax.swing.JComboBox(layers_Str);
        cursor_mode_tool_comp.jCombo = handle(cursor_mode_tool_comp.jCombo,'callbackproperties');
        set(cursor_mode_tool_comp.jCombo, 'SelectedIndex', idx-1);
        set(cursor_mode_tool_comp.jCombo, 'ActionPerformedCallback', {@change_layer,main_figure});
        set(cursor_mode_tool_comp.jCombo,'MaximumSize',java.awt.Dimension(500,500));
        set(cursor_mode_tool_comp.jCombo,'Background',javax.swing.plaf.ColorUIResource(1,1,1))
        set(cursor_mode_tool_comp.jCombo,'ForeGround',javax.swing.plaf.ColorUIResource(0,0,0))
        jToolbar(1).add(cursor_mode_tool_comp.jCombo,6);
        jToolbar(1).repaint;
        jToolbar(1).revalidate;
    end
    
    
    
end

setappdata(main_figure,'Cursor_mode_tool',cursor_mode_tool_comp);
end

function change_layer(hCombo, ~,main_figure)


layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');
itemIndex = get(hCombo,'SelectedIndex');  % 0=topmost item
% itemName  = get(hCombo,'SelectedItem');
new_layer=layers(itemIndex+1);

if new_layer.ID_num==layer.ID_num
    return;
else
    layer=new_layer;
end

setappdata(main_figure,'Layer',layer);
update_display(main_figure,1);
% user processing needs to be placed here

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
        case 'pan'
            curr_disp.CursorMode='Pan';
        case 'ed_bot'
            curr_disp.CursorMode='Edit Bottom';  
    end
else
    curr_disp.CursorMode='Normal';
end

setappdata(main_figure,'Curr_disp',curr_disp);
end









