function keyboard_func(~,callbackdata,main_figure)
cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);
Time=trans.Data.Time;
Number=trans.Data.get_numbers();
Range=trans.Data.get_range();
Dist=trans.GPSDataPing.Dist;

switch curr_disp.Xaxes
    case 'Time'
        xdata=Time;
    case 'Distance'
        xdata=Dist;
    case 'Number'
        xdata=Number;
end
ydata=Range;

switch callbackdata.Key
    case {'leftarrow','rightarrow','uparrow','downarrow'}
        
        axes_panel_comp=getappdata(main_figure,'Axes_panel');
        main_axes=axes_panel_comp.main_axes;
        if ~isfield(axes_panel_comp,'main_echo')
            return;
        end
        
        x_lim=double(get(main_axes,'xlim'));
        y_lim=double(get(main_axes,'ylim'));
        dx=(x_lim(2)-x_lim(1));
        dy=(y_lim(2)-y_lim(1));
        switch callbackdata.Key
            case 'leftarrow'
                if x_lim(1)<=xdata(1)
                    return;
                else
                    x_lim=[nanmax(xdata(1),x_lim(1)-dx/4),nanmax(xdata(1),x_lim(1)-dx/4)+dx];
                end
                set(main_axes,'xlim',x_lim);
                set(main_axes,'ylim',y_lim);
            case 'rightarrow'
                if x_lim(2)>=xdata(end)
                    return;
                else
                    x_lim=[nanmin(xdata(end),x_lim(2)+dx/4)-dx,nanmin(xdata(end),x_lim(2)+dx/4)];
                end
                set(main_axes,'xlim',x_lim);
                set(main_axes,'ylim',y_lim);
            case 'downarrow'
                if y_lim(2)>=ydata(end)
                    return;
                else
                    y_lim=[nanmin(ydata(end),y_lim(2)+dy/4)-dy,nanmin(ydata(end),y_lim(2)+dy/4)];
                end
                set(main_axes,'ylim',y_lim);
            case 'uparrow'
                if y_lim(1)<=ydata(1)
                    return;
                else
                    y_lim=[nanmax(ydata(1),y_lim(1)-dy/4),nanmax(ydata(1),y_lim(1)-dy/4)+dy];
                end
                set(main_axes,'ylim',y_lim);
        end
        
    case '1'
        
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
    case '2'
        
        switch get(cursor_mode_tool_comp.bad_trans,'state');
            case 'off'
                set(cursor_mode_tool_comp.bad_trans,'state','on');
                curr_disp.CursorMode='Bad Transmits';
            case 'on'
                set(cursor_mode_tool_comp.bad_trans,'state','off');
                curr_disp.CursorMode='Normal';
        end
        %toggle_func(cursor_mode_tool_comp.bad_trans,[],main_figure);
    case '3'
        
        switch get(cursor_mode_tool_comp.edit_bottom,'state');
            case 'off'
                set(cursor_mode_tool_comp.edit_bottom,'state','on');
                curr_disp.CursorMode='Edit Bottom';
            case 'on'
                set(cursor_mode_tool_comp.edit_bottom,'state','off');
                curr_disp.CursorMode='Normal';
        end
        %toggle_func(cursor_mode_tool_comp.edit_bottom,[],main_figure);
    case '4'
        curr_disp.CursorMode='Create Region';
        reset_mode(0,0,main_figure);
        set(main_figure,'WindowButtonDownFcn',{@create_region,main_figure});
    case '5'
        curr_disp.CursorMode='Normal';
        reset_mode(0,0,main_figure);
    case 'b'
        
        switch curr_disp.DispUnderBottom
            case 'off'
                curr_disp.DispUnderBottom='on';
            case 'on'
                curr_disp.DispUnderBottom='off';
        end
        
    case 'c'
        cmaps={'jet' 'hsv' 'esp2' 'ek500'};
        id_map=find(strcmp(curr_disp.Cmap,cmaps));
        curr_disp.Cmap=cmaps{nanmin(rem(id_map,length(cmaps))+1,length(cmaps))};
    case 'f'
        id_freq=layer.find_freq_idx(curr_disp.Freq);
        curr_disp.Freq=layer.Frequencies(nanmin(rem(id_freq,length(layer.Frequencies))+1,length(layer.Frequencies)));
end

end