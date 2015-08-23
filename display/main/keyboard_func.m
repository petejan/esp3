function keyboard_func(~,callbackdata,main_figure)

cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');

switch callbackdata.Key
    case {'leftarrow','rightarrow','uparrow','downarrow'}
        
        axes_panel_comp=getappdata(main_figure,'Axes_panel');
        main_axes=axes_panel_comp.main_axes;
        if ~isfield(axes_panel_comp,'main_echo')
            return;
        end
        main_echo=axes_panel_comp.main_echo;
        x=double(get(main_axes,'xlim'));
        y=double(get(main_axes,'ylim'));
        xdata=double(get(main_echo,'Xdata'));
        ydata=double(get(main_echo,'Ydata'));
        nb_x=100;
        nb_y=100;
        x_vec=linspace(xdata(1),xdata(end),nb_x);
        y_vec=linspace(ydata(1),ydata(end),nb_y);
        
        [~,idx_curr_pos_xmin]=nanmin(abs(x_vec-x(1)));
        [~,idx_curr_pos_xmax]=nanmin(abs(x_vec-x(2)));
        x_w=idx_curr_pos_xmax-idx_curr_pos_xmin;
        
        [~,idx_curr_pos_ymin]=nanmin(abs(y_vec-y(1)));
        [~,idx_curr_pos_ymax]=nanmin(abs(y_vec-y(2)));
        y_w=idx_curr_pos_ymax-idx_curr_pos_ymin;
        
        switch callbackdata.Key
            case 'leftarrow'
                idx1=nanmin(nanmax(idx_curr_pos_xmin-1,1),nb_x-x_w);
                idx2=idx1+x_w;
                set(main_axes,'xlim',[x_vec(idx1) x_vec(idx2)]);
            case 'rightarrow'
                idx1=nanmin(idx_curr_pos_xmin+1,nb_x-x_w);
                idx2=idx1+x_w;
                set(main_axes,'xlim',[x_vec(idx1) x_vec(idx2)]);
            case 'downarrow'
                idx1=nanmin(idx_curr_pos_ymin+1,nb_y-y_w);
                idx2=idx1+y_w;
                set(main_axes,'ylim',[y_vec(idx1) y_vec(idx2)]);
            case 'uparrow'
                idx1=nanmin(nanmax(idx_curr_pos_ymin-1,1),nb_y-y_w);
                idx2=idx1+y_w;
                set(main_axes,'ylim',[y_vec(idx1) y_vec(idx2)]);
                
        end
        
    case '1'
        switch get(cursor_mode_tool_comp.zoom_in,'state');
            case 'off'
                set(cursor_mode_tool_comp.zoom_in,'state','on');
            case 'on'
                set(cursor_mode_tool_comp.zoom_in,'state','off');
        end
        toggle_func(cursor_mode_tool_comp.zoom_in,[],main_figure);
    case '2'
        
        switch get(cursor_mode_tool_comp.zoom_out,'state');
            case 'off'
                set(cursor_mode_tool_comp.zoom_out,'state','on');
            case 'on'
                set(cursor_mode_tool_comp.zoom_out,'state','off');
        end
        toggle_func(cursor_mode_tool_comp.zoom_out,[],main_figure);
        
end

end