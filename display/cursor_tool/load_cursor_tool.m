function load_cursor_tool(main_figure)

app_path=getappdata(main_figure,'App_path');
if isappdata(main_figure,'Cursor_mode_tool')
    cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
    delete(cursor_mode_tool_comp.cursor_mode_tool);
    rmappdata(main_figure,'Cursor_mode_tool');
end


curr_disp=getappdata(main_figure,'Curr_disp');  
layer=getappdata(main_figure,'Layer');
layers=getappdata(main_figure,'Layers');
%idx_freq=find_freq_idx(layer,curr_disp.Freq);
nb_layers=length(layers);


layers_Str=cell(1,nb_layers);
for i=nb_layers:-1:1
    if iscell(layers(i).Filename)
        new_name=layers(i).Filename{1};
    else
        new_name=layers(i).Filename;
    end
    u=1;
    new_name_ori=new_name;
    while nansum(strcmp(new_name,layers_Str))>=1
        new_name=[new_name_ori num2str(u)];
        u=u+1;
    end
    layers_Str{i}=new_name;
end



cursor_mode_tool_comp.cursor_mode_tool=uitoolbar(main_figure);

if isdeployed
    icon=get_icons_cdata([]);
else
    icon=get_icons_cdata([app_path.main 'icons\']);
end

cursor_mode_tool_comp.zoom_in=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.zin,'TooltipString','Zoom +','Tag','zin');
cursor_mode_tool_comp.zoom_out=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.zout,'TooltipString','Zoom -','Tag','zout');
cursor_mode_tool_comp.pan=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.pan ,'TooltipString','Pan','Tag','pan');
cursor_mode_tool_comp.edit_bottom=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.edit_bot ,'TooltipString','Edit Bottom','Tag','ed_bot');
%cursor_mode_tool_comp.location=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.ts_cal ,'TooltipString','Display Location','Tag','loc');
cursor_mode_tool_comp.bad_trans=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.bad_trans ,'TooltipString','Bad Transmit','Tag','bt');

% if strcmp(layer.Transceivers(idx_freq).Mode,'FM')
%     cursor_mode_tool_comp.freq_dist=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.fplot,'TooltipString','Freqency Distribution','Tag','fd');
% end
% 
% cursor_mode_tool_comp.ts_cal=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.ts_cal,'TooltipString','TS Calibration','Tag','ts_cal');
% cursor_mode_tool_comp.eba_cal=uitoggletool(cursor_mode_tool_comp.cursor_mode_tool,'CData',icon.eba_cal,'TooltipString','EBA Calibration','Tag','eba_cal');

childs=findall(main_figure,'type','uitoggletool');
set(childs,...
     'ClickedCallback',{@toggle_func,main_figure});
 
 [idx,~]=find_layer_idx(layers,layer.ID_num);

 %jToolbar = get(get(cursor_mode_tool_comp.cursor_mode_tool,'JavaContainer'),'ComponentPeer');
 jToolbar = findjobj(gcf,'-nomenu','class','mjtoolbar');
 if ~isempty(jToolbar)
     cursor_mode_tool_comp.jCombo = javax.swing.JComboBox(layers_Str);
     cursor_mode_tool_comp.jCombo = handle(cursor_mode_tool_comp.jCombo,'callbackproperties');
     set(cursor_mode_tool_comp.jCombo, 'SelectedIndex', idx-1);
     set(cursor_mode_tool_comp.jCombo, 'ActionPerformedCallback', {@change_layer,main_figure});
     set(cursor_mode_tool_comp.jCombo,'MaximumSize',java.awt.Dimension(250,250));
     set(cursor_mode_tool_comp.jCombo,'Background',javax.swing.plaf.ColorUIResource(1,1,1))
     set(cursor_mode_tool_comp.jCombo,'ForeGround',javax.swing.plaf.ColorUIResource(0,0,0))
     jToolbar(1).add(cursor_mode_tool_comp.jCombo,6); 
     jToolbar(1).repaint;
     jToolbar(1).revalidate;
 end
 

% set(main_figure,'KeyPressFcn',{@key_switch,main_figure});
% set(main_figure,'KeyReleaseFcn',{@key_switch,main_figure});

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


function toggle_func(src, ~,main_figure)
%cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
reset_disp_info(main_figure);
ah=axes_panel_comp.main_axes;
axes(ah);
h=zoom;
h_pan=pan;
type=src.Tag;

childs=findall(main_figure,'type','uitoggletool');

for i=1:length(childs)
    
    if ~strcmp(get(childs(i),'tag'),type)
        set(childs(i),'state','off');
    end
    
end

region_tab_comp=getappdata(main_figure,'Region_tab');
set(region_tab_comp.create_button,'value',get(region_tab_comp.create_button,'Min'));


if strcmp(src.State,'on')
    switch type
        case 'zin'
            set(h,'Enable','on','Direction','in');
        case 'zout'
            set(h,'Enable','on','Direction','out');
        case 'fd'
            set(h,'Enable','off');
            switch(curr_disp.Fieldname)
                case {'Sv','Sp'}
                    set(main_figure,'WindowButtonDownFcn',{@freq_response,main_figure});
                otherwise
                    set(main_figure,'WindowButtonDownFcn','');
            end
            
        case 'ts_cal'
            set(h,'Enable','off');
            set(h_pan,'Enable','off');
            switch(curr_disp.Fieldname)
                case {'Sp','Sv'}
                    set(main_figure,'WindowButtonDownFcn',{@TS_calibration_curves,main_figure});
                otherwise
                    set(main_figure,'WindowButtonDownFcn','');
            end
        case 'eba_cal'
                        set(h,'Enable','off');
            set(h_pan,'Enable','off');
            switch(curr_disp.Fieldname)
                case {'Sp','Sv'}
                    set(main_figure,'WindowButtonDownFcn',{@beamwidth_calibration_curves,main_figure});
                otherwise
                    set(main_figure,'WindowButtonDownFcn','');
            end
        case 'bt'
            set(h,'Enable','off');
            set(h_pan,'Enable','off');
            set(main_figure,'WindowButtonDownFcn',@(src,envdata)mark_bad_transmit(src,envdata,main_figure));
        case 'pan'
            set(h,'Enable','off');
            set(main_figure,'WindowButtonDownFcn','');
            set(h_pan,'Enable','on');
            
        case 'ed_bot'
            set(h,'Enable','off');
            set(h_pan,'Enable','off');
            set(main_figure,'WindowButtonDownFcn',@(src,envdata)edit_bottom(src,envdata,main_figure));
                        
        case 'loc'
            set(h,'Enable','off');
            set(h_pan,'Enable','off');
            set(main_figure,'WindowButtonDownFcn',@(src,envdata)disp_loc(src,envdata,main_figure));
    end
else
    set(h_pan,'Enable','off');
    set(h,'Enable','off');
    set(main_figure,'WindowButtonDownFcn','');
end

end
% 
% function display_freq_response(src,~,main_figure)
% 
% curr_disp=getappdata(main_figure,'Curr_disp');  
% switch(curr_disp.Fieldname)
%     case 'Sv'
%         set(main_figure,'WindowButtonDownFcn',{@display_sv_freq_response_v2,main_figure});
%     case 'Sp'
%         set(main_figure,'WindowButtonDownFcn',{@display_TS_freq_response_v2,main_figure});
%     otherwise
%         set(main_figure,'WindowButtonDownFcn','');
% end
%       
% 
% end



function key_switch(~,callbackdata,main_figure)
cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');

switch callbackdata.Key
    case '1'
        set(cursor_mode_tool_comp.zoom_in,'state','on');
        toggle_func(cursor_mode_tool_comp.zoom_in,[],main_figure);
    case '2'
        set(cursor_mode_tool_comp.zoom_out,'state','on');
        toggle_func(cursor_mode_tool_comp.zoom_out,[],main_figure);
end

end