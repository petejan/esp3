function load_cursor_tool(main_figure)

if ~isdeployed
    disp('Loading Toolbar');
end
%curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
layers=getappdata(main_figure,'Layers');

nb_layers=length(layers);
if nb_layers>0
    layers_Str=list_layers(layers,'nb_char',80);
    layers_Str_comp=list_layers(layers);
else
    layers_Str={'--'};
    layers_Str_comp={'--'};
    layer=layer_cl();
    layers=layer;
end

[path_lay,~]=layer.get_path_files();

if isappdata(main_figure,'Cursor_mode_tool')
    cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
    [idx_curr,~]=layers.find_layer_idx(layer.ID_num);
    
    if cursor_mode_tool_comp.jCombo.ItemCount~=nb_layers||nb_layers==1
        set(cursor_mode_tool_comp.jCombo, 'ActionPerformedCallback','');
        cursor_mode_tool_comp.jCombo.removeAllItems();
        
        for i=1:nb_layers
            cursor_mode_tool_comp.jCombo.addItem(layers_Str{i});
        end
        
        set(cursor_mode_tool_comp.jCombo, 'SelectedIndex', idx_curr-1);
        set(cursor_mode_tool_comp.jCombo,'ToolTipText',[path_lay{1} layers_Str_comp{idx_curr}]);
        set(cursor_mode_tool_comp.jCombo, 'ActionPerformedCallback',{@change_layer,main_figure});
    end
    
else
    
    cursor_mode_tool_comp.cursor_mode_tool=uitoolbar(main_figure,'Tag','toolbar_esp3');
    app_path_main=whereisEcho();
    icon=get_icons_cdata(fullfile(app_path_main,'icons'));
    
    cursor_mode_tool_comp.zoom_in=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.zin,'TooltipString','Zoom +','Tag','zin');
    cursor_mode_tool_comp.zoom_out=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.zout,'TooltipString','Zoom -','Tag','zout');
    cursor_mode_tool_comp.bad_trans=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.bad_trans ,'TooltipString','Bad Transmit','Tag','bt');
    cursor_mode_tool_comp.edit_bottom=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.edit_bot ,'TooltipString','Edit Bottom','Tag','ed_bot');
    cursor_mode_tool_comp.measure=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.ruler ,'TooltipString','Measure Distance','Tag','meas');
    
    childs=findall(main_figure,'type','uitoggletool');
    set(childs,...
        'ClickedCallback',{@set_curr_disp_mode,main_figure});
    
    [idx,~]=find_layer_idx(layers,layer.ID_num);
    
    %jToolbar = get(get(cursor_mode_tool_comp.cursor_mode_tool,'JavaContainer'),'ComponentPeer
    warning('off', 'YMA:FindJObj:invisibleHandle');
    jToolbar = findjobj(main_figure,'-nomenu','class','mjtoolbar');
    
    if ~isempty(jToolbar)
        cursor_mode_tool_comp.jCombo = javax.swing.JComboBox(layers_Str);
        cursor_mode_tool_comp.jCombo = handle(cursor_mode_tool_comp.jCombo,'callbackproperties');
        set(cursor_mode_tool_comp.jCombo, 'SelectedIndex', idx-1);
        set(cursor_mode_tool_comp.jCombo, 'ActionPerformedCallback',{@change_layer,main_figure});
        set(cursor_mode_tool_comp.jCombo,'MaximumSize',java.awt.Dimension(500,500));
        set(cursor_mode_tool_comp.jCombo,'Background',javax.swing.plaf.ColorUIResource(1,1,1))
        set(cursor_mode_tool_comp.jCombo,'ForeGround',javax.swing.plaf.ColorUIResource(0,0,0));
        set(cursor_mode_tool_comp.jCombo,'ToolTipText',[path_lay{1} layers_Str_comp{idx}])
        jToolbar(1).add(cursor_mode_tool_comp.jCombo,6);
        jToolbar(1).repaint;
        jToolbar(1).revalidate;
    end
    
    cursor_mode_tool_comp.previous=uipushtool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.prev_lay ,'TooltipString','Previous Layer','ClickedCallback',{@change_layer_callback,main_figure,'prev'});
    cursor_mode_tool_comp.next=uipushtool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.next_lay ,'TooltipString','Next Layer','ClickedCallback',{@change_layer_callback,main_figure,'next'});
    cursor_mode_tool_comp.del=uipushtool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.del_lay ,'TooltipString','Delete Layer','ClickedCallback',{@delete_layer_callback,main_figure});
    
end

setappdata(main_figure,'Cursor_mode_tool',cursor_mode_tool_comp);
end

function change_layer(hCombo, ~,main_figure)
% profile on;
% disp('Change_layer')

layers=getappdata(main_figure,'Layers');
if isempty(layers)
    return;
end

layer=getappdata(main_figure,'Layer');
itemIndex = get(hCombo,'SelectedIndex');  % 0=topmost item
% itemName  = get(hCombo,'SelectedItem');
new_layer=layers(itemIndex+1);

if new_layer.ID_num==layer.ID_num
    return;
else
    layer=new_layer;
end
check_saved_bot_reg(main_figure);

setappdata(main_figure,'Layer',layer);
loadEcho(main_figure);

% profile off;
% profile viewer; 

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
    end
else
    curr_disp.CursorMode='Normal';
end
setappdata(main_figure,'Curr_disp',curr_disp);
order_axes(main_figure);


end









