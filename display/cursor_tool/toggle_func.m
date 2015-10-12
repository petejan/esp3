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
   axes_panel_comp.main_echo.UIContextMenu=[];
else
    set(h_pan,'Enable','off');
    set(h,'Enable','off');
    set(main_figure,'WindowButtonDownFcn','');
    context_menu=uicontextmenu;
    axes_panel_comp.main_echo.UIContextMenu=context_menu;
    uimenu(context_menu,'Label','Plot Profiles','Callback',{@plot_profiles_callback,main_figure});

end
