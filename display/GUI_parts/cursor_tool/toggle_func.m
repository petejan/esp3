%% toggle_func.m
%
% TODO
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |src|: TODO
% * |main_figure|: Handle to main ESP3 window
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function toggle_func(src, ~,main_figure)

%cursor_mode_tool_comp=getappdata(main_figure,'Cursor_mode_tool');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
%curr_disp=getappdata(main_figure,'Curr_disp');
%reset_disp_info(main_figure);
ah=axes_panel_comp.main_axes;
axes(ah);

switch class(src)
    case {'matlab.ui.container.toolbar.ToggleTool','matlab.ui.container.toolbar.PushTool','matlab.ui.container.toolbar.ToggleSplitTool'}
        type=src.Tag;
        src_out=src;
    case 'char'
        src_out.State='on';
        type=src;
end


childs=[findall(main_figure,'type','uitoggletool');findall(main_figure,'type','uitogglesplittool')];
for i=1:length(childs)
    if ~strcmp(get(childs(i),'tag'),type)
        set(childs(i),'state','off');
    end
end

initialize_interactions_v2(main_figure);


if isa(src_out,'matlab.ui.container.toolbar.PushTool')
    return;
end

if isa(src_out,'matlab.ui.container.toolbar.ToggleSplitTool')||isa(src_out,'matlab.ui.container.toolbar.ToggleTool')
    state=src_out.State;
else
    state='on';
end

switch state
    case'on'
        iptPointerManager(main_figure,'disable');
        axes_panel_comp.bad_transmits.UIContextMenu=[];
        axes_panel_comp.bottom_plot.UIContextMenu=[];
        switch type
            case 'zin'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@zoom_in_callback,main_figure});
            case 'zout'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@zoom_out_callback,main_figure});
            case 'bt'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@mark_bad_transmit,main_figure});
            case 'ed_bot'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@edit_bottom,main_figure});
            case 'ed_bot_sup'
                delete(findall(ancestor(axes_panel_comp.bad_transmits,'figure'),'Tag','btCtxtMenu'));
                context_menu=uicontextmenu(ancestor(axes_panel_comp.bad_transmits,'figure'),'Tag','btCtxtMenu');
                axes_panel_comp.bad_transmits.UIContextMenu=context_menu;
                uimenu(context_menu,'Label','Small','userdata',5,'Callback',@check_only_one);
                uimenu(context_menu,'Label','Medium','userdata',10,'Callback',@check_only_one,'checked','on');
                uimenu(context_menu,'Label','Large','userdata',20,'Callback',@check_only_one);
                uimenu(context_menu,'Label','Extra','userdata',50,'Callback',@check_only_one);
                
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@detect_bottom_supervised,main_figure});
            case 'ed_bot_spline'
                 
                delete(findall(ancestor(axes_panel_comp.bad_transmits,'figure'),'Tag','btCtxtMenu'));
                context_menu=uicontextmenu(ancestor(axes_panel_comp.bad_transmits,'figure'),'Tag','btCtxtMenu');
                axes_panel_comp.bad_transmits.UIContextMenu=context_menu;
                uimenu(context_menu,'Label','Small radius (2px)','userdata',2,'Callback',@check_only_one);
                uimenu(context_menu,'Label','Medium radius (5px)','userdata',5,'Callback',@check_only_one,'checked','on');
                uimenu(context_menu,'Label','Large radius (10px)','userdata',10,'Callback',@check_only_one);
                uimenu(context_menu,'Label','Extra Large radius (50px)','userdata',50,'Callback',@check_only_one);
                uimenu(context_menu,'Label','Stupidly Large radius (100px)','userdata',100,'Callback',@check_only_one);
                
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@push_bottom,main_figure});
            case 'loc'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@disp_loc,main_figure});
            case 'meas'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@measure_distance,main_figure});
            case 'create_reg'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@create_region,main_figure});
                %replace_interaction(main_figure,'interaction','KeyPressFcn','id',2,'interaction_fcn',{@cancel_create_region,main_figure});
            case 'draw_line'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@draw_line,main_figure});
            case 'erase_soundings'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@brush_soundings,main_figure});
            otherwise
                reset_mode(0,0,main_figure);
                set_alpha_map(main_figure);
        end
    case 'off'
        reset_mode(0,0,main_figure);
        set_alpha_map(main_figure);
end

end

function check_only_one(src,~)
uimenu_parent=get(src,'Parent');
childs=findall(uimenu_parent,'Type','uimenu');

for i=1:length(childs)
    if src~=childs(i)
        set(childs(i), 'Checked', 'off');
    end
end

set(src, 'Checked', 'on');


end
