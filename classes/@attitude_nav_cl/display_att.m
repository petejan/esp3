%% display_att.m
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
function h_fig = display_att(obj,parenth)

time=obj.Time;
if isempty(obj.Time)
    h_fig=[];
    warning('No Attitude in current layer');
    return;
end
if ~isempty(parenth)
    axes_panel_comp=getappdata(parenth,'Axes_panel');
    if~isempty(axes_panel_comp)
        ah=axes_panel_comp.haxes;
        x=1:numel(time);
    else
        ah=[];
        x=time;
    end
else
    ah=[];
end



heading=obj.Heading;
pitch=obj.Pitch;
roll=obj.Roll;
heave=obj.Heave;
yaw=obj.Yaw;

h_fig=new_echo_figure(parenth,'Name','Attitude','Tag','attitude');
if ~isempty(roll)
    ax= axes(h_fig,'nextplot','add','OuterPosition',[0 0.5 1 0.5]);
    yyaxis(ax,'left');
    ax.YAxis(1).Color = 'r';
    plot(ax,x,heave,'r');
    ylabel(ax,'Heave (m)');
     
    yyaxis(ax,'right');
    plot(ax,x,pitch,'k');
    plot(ax,x,roll,'color',[0 0.5 0]);
    ax.YAxis(2).Color = 'k';
    ax.YAxis(2).TickLabelFormat  = '%g^\\circ';
    legend(ax,'Heave','Pitch','Roll','Location','northeast')
    legend(ax,'boxoff')
    ylabel(ax,'Attitude');
    grid(ax,'on');
    box(ax,'on');
    if isempty(ah)
        datetick(ax,'x');
        xlabel(ax,'Time');
    end
else
    ax=[];
end

if ~isempty(heading)
    heading(heading==-999)=nan;
    axh=axes(h_fig,'nextplot','add','OuterPosition',[0 0 0.5 0.5]);
    axh.YAxis.TickLabelFormat  = '%g^\\circ';
    plot(axh,x,heading,'k');
    ylabel(axh,'Heading');
    grid(axh,'on');
    box(axh,'on');
    if isempty(ah)
        datetick(axh,'x');
        xlabel(axh,'Time');
    end
else
    axh=[];
end

if ~isempty(yaw)
    axy=axes(h_fig,'nextplot','add','OuterPosition',[0.5 0 0.5 0.5]);
    axy.YAxis.TickLabelFormat  = '%g^\\circ';
    plot(axy,time,yaw,'k');
    ylabel(axy,'Yaw');
    grid(axy,'on');
    box(axy,'on');   
    if isempty(ah)
        datetick(axy,'x');
        xlabel(axy,'Time');
    end
else
    axy=[];
end
set([ax axh axy],'XtickLabelRotation',90);
h_fig.UserData=linkprop([ah ax axh axy],{'XTick' 'XTickLabels' 'XLim'});



end