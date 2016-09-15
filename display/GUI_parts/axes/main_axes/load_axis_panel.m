function load_axis_panel(main_figure)

if isappdata(main_figure,'Axes_panel')
    axes_panel_comp=getappdata(main_figure,'Axes_panel');
    delete(axes_panel_comp.axes_pane);
    rmappdata(main_figure,'Axes_panel');
end

axes_panel_comp.axes_panel=uipanel(main_figure,'Units','Normalized','Position',[0 0.05 1 .65],'BackgroundColor',[1 1 1],'tag','axes_panel');
axes_panel_comp.main_axes=axes('Parent',axes_panel_comp.axes_panel,'FontSize',10,'Units','normalized',...
    'Position',[0 0 1 1],...
    'XAxisLocation','bottom',...
    'XLimMode','manual',...
    'YLimMode','manual',...
    'TickDir','in',...
    'XTickLabel',{[]},...
    'YTickLabel',{[]},...
    'box','on',...
    'SortMethod','childorder',...
    'NextPlot','add',...
    'YDir','reverse',...
    'visible','on');

axes_panel_comp.vaxes=axes('Parent',axes_panel_comp.axes_panel,'FontSize',10,'Fontweight','Bold','Units','normalized',...
    'Position',[0 0 0 0],...
    'XAxisLocation','Top',...
    'YAxisLocation','right',...
    'TickLength',[0 0],...
    'visible','on',...
    'box','on',...
    'XTickLabel',{[]},...
    'Xgrid','on',...
    'Ygrid','on',...
    'NextPlot','add',...
    'GridColor',[0 0 0],...
    'YDir','reverse',...
    'visible','on');

axes_panel_comp.v_axes_plot=plot(axes_panel_comp.vaxes,nan,'r');
axes_panel_comp.v_axes_text=text(nan,nan,'','Color','k','VerticalAlignment','bottom','fontsize',10,'parent',axes_panel_comp.vaxes);


axes_panel_comp.haxes=axes('Parent',axes_panel_comp.axes_panel,'FontSize',10,'Fontweight','Bold','Units','normalized',...
    'Position',[0 0 0 0],...
    'XAxisLocation','bottom',...
    'YAxisLocation','left',...
    'TickLength',[0 0],...
    'visible','on',...
    'box','on',...
    'YTickLabel',{[]},...
    'Xgrid','on',...
    'Ygrid','on',...
    'NextPlot','add',...
    'GridColor',[0 0 0],...
    'visible','on');

axes_panel_comp.h_axes_plot=plot(axes_panel_comp.haxes,nan,'k');
axes_panel_comp.h_axes_text=text(nan,nan,'','Color','r','VerticalAlignment','bottom','fontsize',10,'parent',axes_panel_comp.haxes);

axes_panel_comp.colorbar=colorbar(axes_panel_comp.main_axes,'PickableParts','none','visible','off');
axes_panel_comp.main_axes.Position=[0 0 1 1];


echo_init=imread(fullfile(whereisEcho,'EchoAnalysis.png'));

axes_panel_comp.main_echo=imagesc(1:size(echo_init,1),1:size(echo_init,2),echo_init,'parent',axes_panel_comp.main_axes,'tag','echo');
axes_panel_comp.bad_transmits=image(1:size(echo_init,1),1:size(echo_init,2),nan(size(echo_init)),'parent',axes_panel_comp.main_axes,'AlphaData',0,'tag','bad_transmits');
set(axes_panel_comp.main_axes,'xlim',[1 size(echo_init,1)],'ylim',[1 size(echo_init,2)]);
axes_panel_comp.bottom_plot=plot(axes_panel_comp.main_axes,nan,'tag','bottom');
axes_panel_comp.track_plot=[];
axes_panel_comp.listeners=[];


setappdata(main_figure,'Axes_panel',axes_panel_comp);