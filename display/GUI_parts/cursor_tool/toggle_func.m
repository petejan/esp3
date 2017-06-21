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
    case {'matlab.ui.container.toolbar.ToggleTool','matlab.ui.container.toolbar.PushTool'}
        type=src.Tag;
        src_out=src;
    case 'char'
        src_out.State='on';
        type=src;
end


childs=findall(main_figure,'type','uitoggletool');
for i=1:length(childs)
    if ~strcmp(get(childs(i),'tag'),type)
        set(childs(i),'state','off');
    end
end

initialize_interactions_v2(main_figure);

if isa(src_out,'matlab.ui.container.toolbar.PushTool')
    return;
end

switch src_out.State
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
            case 'loc'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@disp_loc,main_figure});
            case 'meas'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@measure_distance,main_figure});
            case 'create_reg'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@create_region,main_figure});
                replace_interaction(main_figure,'interaction','KeyPressFcn','id',2,'interaction_fcn',{@cancel_create_region,main_figure});
            case 'draw_line'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@draw_line,main_figure});
            case 'brush_soundings'
                replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@brush_soundings,main_figure}); 
            otherwise 

                reset_mode(0,0,main_figure);    
        end
    case 'off'
        reset_mode(0,0,main_figure);
end

end
