function toggle_func(src, ~,main_figure)
%cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
reset_disp_info(main_figure);
ah=axes_panel_comp.main_axes;
axes(ah);



type=src.Tag;
childs=findall(main_figure,'type','uitoggletool');
for i=1:length(childs)
    if ~strcmp(get(childs(i),'tag'),type)
        set(childs(i),'state','off');
    end
end

region_tab_comp=getappdata(main_figure,'Region_tab');
set(region_tab_comp.create_button,'value',get(region_tab_comp.create_button,'Min'));

if isa(src,'matlab.ui.container.toolbar.PushTool')
    return;
end

switch src.State
    case'on'
        axes_panel_comp.main_echo.UIContextMenu=[];
        switch type
            case 'zin'
                setptr(main_figure,'glassplus');
                set(main_figure,'WindowButtonDownFcn',{@zoom_in_callback,main_figure});
            case 'zout'
                setptr(main_figure,'glassminus');
                set(main_figure,'WindowButtonDownFcn',{@zoom_out_callback,main_figure});
            case 'fd'
                switch(curr_disp.Fieldname)
                    case {'Sv','Sp'}
                        set(main_figure,'WindowButtonDownFcn',{@freq_response,main_figure});
                    otherwise
                        set(main_figure,'WindowButtonDownFcn','');
                end
                
            case 'ts_cal'
                switch(curr_disp.Fieldname)
                    case {'Sp','Sv'}
                        set(main_figure,'WindowButtonDownFcn',{@TS_calibration_curves,main_figure});
                    otherwise
                        set(main_figure,'WindowButtonDownFcn','');
                end
            case 'eba_cal'
                switch(curr_disp.Fieldname)
                    case {'Sp','Sv'}
                        set(main_figure,'WindowButtonDownFcn',{@beamwidth_calibration_curves,main_figure});
                    otherwise
                        set(main_figure,'WindowButtonDownFcn','');
                end
            case 'bt'
                set(main_figure,'Pointer','arrow');
                set(main_figure,'WindowButtonDownFcn',@(src,envdata)mark_bad_transmit(src,envdata,main_figure));
            case 'pan'
                set(main_figure,'WindowButtonDownFcn','');
            case 'ed_bot'
                set(main_figure,'Pointer','arrow');
                set(main_figure,'WindowButtonDownFcn',@(src,envdata)edit_bottom(src,envdata,main_figure));
            case 'loc'
                set(main_figure,'Pointer','arrow');
                set(main_figure,'WindowButtonDownFcn',@(src,envdata)disp_loc(src,envdata,main_figure));
        end
        axes_panel_comp.main_echo.UIContextMenu=[];
    case 'off'
        set(main_figure,'Pointer','arrow');
        set(main_figure,'WindowButtonDownFcn','');
        create_context_menu_main_echo(main_figure,axes_panel_comp.main_echo);
end
