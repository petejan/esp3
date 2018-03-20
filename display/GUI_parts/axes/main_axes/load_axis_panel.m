%% load_axis_panel.m
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
% * |axes_panel|: TODO: write description and info on variable
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
function load_axis_panel(main_figure,axes_panel)

if isappdata(main_figure,'Axes_panel')
    axes_panel_comp=getappdata(main_figure,'Axes_panel');
    delete(axes_panel_comp.axes_panel);
    rmappdata(main_figure,'Axes_panel');
end

axes_panel_comp.axes_panel=axes_panel;

axes_panel_comp.main_axes=axes('Parent',axes_panel_comp.axes_panel,...
    'FontSize',10,'Units','normalized',...
    'Position',[0 0 1 1],...
    'XAxisLocation','bottom',...
    'XLimMode','manual',...
    'YLimMode','manual',...
    'TickLength',[0 0],...
    'XTickLabel',{[]},...
    'YTickLabel',{[]},...
    'box','on',...
    'SortMethod','childorder',...
    'XMinorGrid','on',...
    'YMinorGrid','on',...
    'GridLineStyle','--',...
    'NextPlot','add',...
    'YDir','reverse',...
    'visible','on',...
    'ClippingStyle','rectangle',...
    'Tag','main');

axes_panel_comp.vaxes=axes('Parent',axes_panel_comp.axes_panel,'FontSize',10,'Fontweight','Bold','Units','normalized',...
    'Position',[0 0 0 0],...
    'XAxisLocation','Top',...
    'YAxisLocation','right',...
    'TickDir','in',...
    'visible','on',...
    'box','on',...
    'XTickLabel',{[]},...
    'Xgrid','on',...
    'Ygrid','on',...
    'NextPlot','add',...
    'ClippingStyle','rectangle',...
    'GridColor',[0 0 0],...
    'YDir','reverse',...
    'visible','on');



axes_panel_comp.v_axes_plot=plot(axes_panel_comp.vaxes,nan,nan,'r');
axes_panel_comp.v_axes_text=text(nan,nan,'','Color','k','HorizontalAlignment','center','VerticalAlignment','bottom','fontsize',10,'parent',axes_panel_comp.vaxes,'Clipping', 'on');


axes_panel_comp.haxes=axes('Parent',axes_panel_comp.axes_panel,'FontSize',10,'Fontweight','Bold','Units','normalized',...
    'Position',[0 0 0 0],...
    'XAxisLocation','bottom',...
    'YAxisLocation','left',...
    'TickDir','in',...
    'visible','on',...
    'box','on',...
    'YTickLabel',{[]},...
    'Xgrid','on',...
    'Ygrid','on',...
    'ClippingStyle','rectangle',...
    'NextPlot','add',...
    'GridColor',[0 0 0],...
    'visible','on');

linkaxes([axes_panel_comp.main_axes axes_panel_comp.haxes],'x');
linkaxes([axes_panel_comp.main_axes axes_panel_comp.vaxes],'y');

enterFcnv =  @(figHandle, currentPoint)...
    set(figHandle, 'Pointer', 'right');
iptSetPointerBehavior(axes_panel_comp.vaxes,enterFcnv);

enterFcnh =  @(figHandle, currentPoint)...
    set(figHandle, 'Pointer', 'top');
iptSetPointerBehavior(axes_panel_comp.haxes,enterFcnh);

iptaddcallback(axes_panel_comp.vaxes,'ButtonDownFcn',{@change_axes_ratio_cback,main_figure,'v'});
iptaddcallback(axes_panel_comp.haxes,'ButtonDownFcn',{@change_axes_ratio_cback,main_figure,'h'});


axes_panel_comp.h_axes_plot_low=plot(axes_panel_comp.haxes,nan,nan,'color',[0 0.5 0]);
axes_panel_comp.h_axes_plot_high=plot(axes_panel_comp.haxes,nan,nan,'color',[0.5 0 0],'linestyle','-','marker','o','MarkerFaceColor',[0.5 0 0]);

axes_panel_comp.h_axes_text=text(nan,nan,'','Color','r','VerticalAlignment','bottom','fontsize',10,'parent',axes_panel_comp.haxes,'Clipping', 'on');

axes_panel_comp.colorbar=colorbar(axes_panel_comp.main_axes,'PickableParts','none','visible','off');
axes_panel_comp.main_axes.Position=[0 0 1 1];


%echo_init=imread(fullfile(whereisEcho,'EchoAnalysis.png'));
echo_init=[0 0];
axes_panel_comp.main_echo=image(1:size(echo_init,1),1:size(echo_init,2),uint8(echo_init),'parent',axes_panel_comp.main_axes,'tag','echo','CDataMapping','scaled','AlphaData',0,'AlphaDataMapping','direct');
axes_panel_comp.bad_transmits=image(1:size(echo_init,1),1:size(echo_init,2),zeros(size(echo_init),'uint8'),'parent',axes_panel_comp.main_axes,'AlphaData',0,'tag','bad_transmits','AlphaDataMapping','direct');

%set(axes_panel_comp.main_axes,'xlim',[1 size(echo_init,1)],'ylim',[1 size(echo_init,2)]);

axes_panel_comp.bottom_plot=plot(axes_panel_comp.main_axes,nan,nan,'tag','bottom');
enterFcn =  @(figHandle, currentPoint)...
    set(figHandle, 'Pointer', 'hand');
iptSetPointerBehavior(axes_panel_comp.bottom_plot,enterFcn);

axes_panel_comp.track_plot=[];
axes_panel_comp.listeners=[];
axes_panel_comp.link_proph=linkprop([axes_panel_comp.haxes axes_panel_comp.main_axes],{'GridLineStyle','XTick','XColor'});
axes_panel_comp.link_propv=linkprop([axes_panel_comp.vaxes axes_panel_comp.main_axes],{'GridLineStyle','YTick','YDir','YColor'});

setappdata(main_figure,'Axes_panel',axes_panel_comp);