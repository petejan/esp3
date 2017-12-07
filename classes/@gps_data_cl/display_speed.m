%% display_speed.m
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
% * |obj|: TODO: write description and info on variable
% * |parenth|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |h_fig|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-29: header (Alex Schimel).
% * YYYY-MM-DD: first version (Author). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function h_fig = display_speed(obj,parenth)

if isempty(obj.Time)
    h_fig=[];
    return;
end

% if ~isempty(parenth)
%     axes_panel_comp=getappdata(parenth,'Axes_panel');
%     if~isempty(axes_panel_comp)
%         ah=axes_panel_comp.main_axes;
%     else
%         ah=[];
%     end
% else
%     ah=[];
% end


dist=obj.Dist;
time=obj.Time(1:end);
if any(dist>0)
    speed=diff(dist/1852)./diff(time*24*60*60/3600);
    h_fig=new_echo_figure(parenth,'Name','Speed','Tag','attitude');
    ax= axes(h_fig,'nextplot','add','OuterPosition',[0 0 1 1]);
    plot(ax,time(2:end),speed,'k');
    xlabel(ax,'Time(s)');
    ylabel(ax,'Speed (knot)');
    grid(ax,'on');
    box(ax,'on');
    xlim(ax,[time(2) time(end)]);
    xt=get(ax,'XTick');
    xt_n=datestr(xt,'HH:MM:SS');
    set(ax,'XtickLabels',xt_n,'XtickLabelRotation',90)
    
else
    h_fig=[];
end

%linkaxes([ah ax],'x');

end