function keyboard_func(src,callbackdata,main_figure)
cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
%curr_disp=getappdata(main_figure,'Curr_disp');

% if ~any(strcmpi(curr_disp.CursorMode,{'Normal','Edit Bottom'}))
%     return;
% end

layer=getappdata(main_figure,'Layer');curr_disp=getappdata(main_figure,'Curr_disp');
if ~isempty(layer)
    [idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
    trans=layer.Transceivers(idx_freq);
    Number=trans.get_transceiver_pings();
    Range=trans.get_transceiver_range();
    
    xdata=Number;
    ydata=Range;
else
    layer=layer_cl();
    idx_freq=1;
    trans=transceiver_cl();
    xdata=[1 1];
    ydata=[1 1];
end


switch callbackdata.Key
    
    
    case {'leftarrow','rightarrow','uparrow','downarrow','a','d'}
        set(src,'KeyPressFcn','');
        axes_panel_comp=getappdata(main_figure,'Axes_panel');
        main_axes=axes_panel_comp.main_axes;
        
        if ~isfield(axes_panel_comp,'main_echo')
            set(src,'KeyPressFcn',{@keyboard_func,main_figure});
            return;
        end
        
        x_lim=double(get(main_axes,'xlim'));
        y_lim=double(get(main_axes,'ylim'));
        dx=(x_lim(2)-x_lim(1));
        dy=(y_lim(2)-y_lim(1));
        switch callbackdata.Key
            case {'leftarrow' 'a'}
                if x_lim(1)<=xdata(1)
                    set(src,'KeyPressFcn',{@keyboard_func,main_figure});
                    return;
                else
                    x_lim=[nanmax(xdata(1),x_lim(1)-0.2*dx),nanmax(xdata(1),x_lim(1)-0.2*dx)+dx];
                end
                set(main_axes,'xlim',x_lim);
                set(main_axes,'ylim',y_lim);
            case {'rightarrow' 'd'}
                if x_lim(2)>=xdata(end)
                    set(src,'KeyPressFcn',{@keyboard_func,main_figure});
                    return;
                else
                    x_lim=[nanmin(xdata(end),x_lim(2)+0.2*dx)-dx,nanmin(xdata(end),x_lim(2)+0.2*dx)];
                end
                set(main_axes,'xlim',x_lim);
                set(main_axes,'ylim',y_lim);
            case 'downarrow'
                if y_lim(2)>=ydata(end)
                    set(src,'KeyPressFcn',{@keyboard_func,main_figure});
                    return;
                else
                    y_lim=[nanmin(ydata(end),y_lim(2)+0.2*dy)-dy,nanmin(ydata(end),y_lim(2)+0.2*dy)];
                end
                set(main_axes,'ylim',y_lim);
            case 'uparrow'
                if y_lim(1)<=ydata(1)
                    set(src,'KeyPressFcn',{@keyboard_func,main_figure});
                    return;
                else
                    y_lim=[nanmax(ydata(1),y_lim(1)-0.2*dy),nanmax(ydata(1),y_lim(1)-0.2*dy)+dy];
                end
                set(main_axes,'ylim',y_lim);
        end
        set(src,'KeyPressFcn',{@keyboard_func,main_figure});
    case {'1' 'numpad1'}
        
        if isempty(callbackdata.Modifier)
            zi='zin';
        elseif strcmpi(callbackdata.Modifier,'shift')
            zi='zout';
        else
            return;
        end
        
        switch zi
            case 'zin'
                
                switch get(cursor_mode_tool_comp.zoom_in,'state');
                    case 'off'
                        set(cursor_mode_tool_comp.zoom_in,'state','on');
                        curr_disp.CursorMode='Zoom In';
                    case 'on'
                        set(cursor_mode_tool_comp.zoom_in,'state','off');
                        curr_disp.CursorMode='Normal';
                end
            case 'zout'
                switch get(cursor_mode_tool_comp.zoom_out,'state');
                    case 'off'
                        set(cursor_mode_tool_comp.zoom_out,'state','on');
                        curr_disp.CursorMode='Zoom Out';
                    case 'on'
                        set(cursor_mode_tool_comp.zoom_out,'state','off');
                        curr_disp.CursorMode='Normal';
                        
                        
                        
                end
        end
        %toggle_func(cursor_mode_tool_comp.zoom_in,[],main_figure);
    case {'2' 'numpad2'}
        
        switch get(cursor_mode_tool_comp.bad_trans,'state');
            case 'off'
                set(cursor_mode_tool_comp.bad_trans,'state','on');
                curr_disp.CursorMode='Bad Transmits';
            case 'on'
                set(cursor_mode_tool_comp.bad_trans,'state','off');
                curr_disp.CursorMode='Normal';
        end
        %toggle_func(cursor_mode_tool_comp.bad_trans,[],main_figure);
    case {'3' 'numpad3'}
        
        switch get(cursor_mode_tool_comp.edit_bottom,'state');
            case 'off'
                set(cursor_mode_tool_comp.edit_bottom,'state','on');
                curr_disp.CursorMode='Edit Bottom';
            case 'on'
                set(cursor_mode_tool_comp.edit_bottom,'state','off');
                curr_disp.CursorMode='Normal';
        end
        %toggle_func(cursor_mode_tool_comp.edit_bottom,[],main_figure);
    case {'4' 'numpad4'}
        switch curr_disp.CursorMode
            case 'Create Region'
                curr_disp.CursorMode='Normal';
            otherwise
                curr_disp.CursorMode='Create Region';
        end
    case {'5' 'numpad5'}
        curr_disp.CursorMode='Normal';
    case {'b','pagedown'}
        
        switch curr_disp.DispUnderBottom
            case 'off'
                curr_disp.DispUnderBottom='on';
            case 'on'
                curr_disp.DispUnderBottom='off';
        end
    case 'r'
        
        switch curr_disp.DispReg
            case 'off'
                curr_disp.DispReg='on';
            case 'on'
                curr_disp.DispReg='off';
        end
    case 't'
        
        switch curr_disp.DispBadTrans
            case 'off'
                curr_disp.DispBadTrans='on';
            case 'on'
                curr_disp.DispBadTrans='off';
        end
        
    case 'c'
        cmaps={'ek60' 'esp2' 'ek500' 'jet' 'hsv' };
        id_map=find(strcmp(curr_disp.Cmap,cmaps));
        if isempty(id_map)
            id_map=0;
        end
        curr_disp.Cmap=cmaps{nanmin(rem(id_map,length(cmaps))+1,length(cmaps))};
    case 'f'
        if length(layer.Frequencies)>1
            set(src,'KeyPressFcn','');
            curr_disp.Freq=layer.Frequencies(nanmin(rem(idx_freq,length(layer.Frequencies))+1,length(layer.Frequencies)));
            set(src,'KeyPressFcn',{@keyboard_func,main_figure});
        end
    case 'e'
        if~isempty(trans.Data)
            set(src,'KeyPressFcn','');
            if length(trans.Data.Fieldname)>1
                fields=trans.Data.Fieldname;
                id_field=find(strcmp(curr_disp.Fieldname,fields));
                curr_disp.setField(fields{nanmin(rem(id_field,length(fields))+1,length(fields))});
            end
            set(src,'KeyPressFcn',{@keyboard_func,main_figure});
        end
        
    case 'n'
        change_layer_callback([],[],main_figure,'next');
    case 'p'
        change_layer_callback([],[],main_figure,'prev');
    case 'add'
        curr_disp=getappdata(main_figure,'Curr_disp');
        curr_disp.setCax(curr_disp.Cax+1);
    case 'subtract'
        curr_disp=getappdata(main_figure,'Curr_disp');
        curr_disp.setCax(curr_disp.Cax-1);
    case 'delete'
        if ~isempty(get(gco,'Tag'))
            switch get(gco,'Tag')
                case {'region','region_text'}
                    id=get(gco,'Userdata'); 
                    idx= trans.list_regions_Unique_ID(id);
                    trans.rm_region_id(get(gco,'Userdata'));     
                   
                    load_region_fig(main_figure,1,-id);
                    update_regions_tab(main_figure,nanmax(idx-1,1));
                    display_regions(main_figure,'both');
                    order_stacks_fig(main_figure);order_axes(main_figure);
            end
        end
    case 'l'
        logbook_dispedit_callback([],[],main_figure)
    case 'w'
        keyboard_zoom(-1,main_figure);
    case 's'
        if isempty(callbackdata.Modifier)
            keyboard_zoom(1,main_figure)
        elseif strcmpi(callbackdata.Modifier,'control')
            save_bot_reg_xml_to_db_callback([],[],main_figure,0,0);
        else
            return;
        end
        
        
        
    case 'z'
       go_to_ping(1,main_figure);
        
    case 'x'
        
       go_to_ping(length(Number),main_figure);
        
end

order_axes(main_figure);
end