%% load_mini_axes.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: Handle to main ESP3 window
% * |parent|: TODO: write description and info on variable
% * |pos_in_parent|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-02: header (Alex Schimel).
% * YYYY-MM-DD: first version (Yoann Ladroit). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function load_mini_axes(main_figure,parent,pos_in_parent)

if isappdata(main_figure,'Mini_axes')
    mini_axes_comp=getappdata(main_figure,'Mini_axes');
    delete(mini_axes_comp.mini_ax);
    rmappdata(main_figure,'Mini_axes');
end


pointerBehavior.enterFcn =  @(figHandle, currentPoint)...
    set(figHandle, 'Pointer', 'fleur');
pointerBehavior.exitFcn  = @(figHandle, currentPoint)...
    set(figHandle, 'Pointer', 'fleur');
pointerBehavior.traverseFcn = @(figHandle, currentPoint)...
    set(figHandle, 'Pointer', 'fleur');

mini_axes_comp.mini_ax=axes('Parent',parent,'Units','normalized','box','on',...
    'Position',pos_in_parent,'visible','on','NextPlot','add','box','on','tag','mini','ClippingStyle','rectangle');

%iptSetPointerBehavior(mini_axes_comp.mini_ax,pointerBehavior);

mini_axes_comp.mini_echo=image(1,1,1,'Parent',mini_axes_comp.mini_ax,'tag','echo','AlphaData',0,'CDataMapping','scaled','AlphaDataMapping','direct');
mini_axes_comp.mini_echo_bt=image(1,1,1,'Parent',mini_axes_comp.mini_ax,'tag','bad_transmits','AlphaData',0,'AlphaDataMapping','direct');
mini_axes_comp.bottom_plot=plot(mini_axes_comp.mini_ax,nan,nan,'tag','bottom');
mini_axes_comp.patch_obj=patch('Faces',[],'Vertices',[],'FaceColor','r','FaceAlpha',.2,'EdgeColor','r','Tag','zoom_area','Parent',mini_axes_comp.mini_ax);

iptSetPointerBehavior(mini_axes_comp.patch_obj,pointerBehavior);

set(mini_axes_comp.mini_ax,'XTickLabels',[],'YTickLabels',[]);

set(mini_axes_comp.patch_obj,'ButtonDownFcn',{@move_patch_mini_axis_grab,main_figure});
set(mini_axes_comp.mini_echo,'ButtonDownFcn',{@zoom_in_callback_mini_ax,main_figure});
set(mini_axes_comp.mini_echo_bt,'ButtonDownFcn',{@zoom_in_callback_mini_ax,main_figure});

if isgraphics(parent,'figure')
    set(parent,'SizeChangedFcn',{@resize_mini_ax,main_figure});
    mini_axes_comp.link_prop=linkprop([main_figure parent],'AlphaMap');
else
    set(mini_axes_comp.mini_ax,'ButtonDownFcn',{@move_mini_axis_grab,main_figure});
end
axes_panel_comp=getappdata(main_figure,'Axes_panel');

mini_axes_comp.link_props=linkprop([axes_panel_comp.main_axes mini_axes_comp.mini_ax],{'YColor','XColor','GridLineStyle','Color','Clim','GridColor','MinorGridColor','YDir'}); 

setappdata(main_figure,'Mini_axes',mini_axes_comp);
update_grid_mini_ax(main_figure)
create_context_menu_mini_echo(main_figure);

end