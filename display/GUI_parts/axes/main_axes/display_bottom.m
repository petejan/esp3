function display_bottom(main_figure)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
mini_axes_comp=getappdata(main_figure,'Mini_axes');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,~]=layer.get_trans(curr_disp);

idx_bottom=trans_obj.Bottom.Sample_idx;
xdata=trans_obj.get_transceiver_pings();
ydata=trans_obj.get_transceiver_samples();

bad_ping_tab_comp=getappdata(main_figure,'Bad_ping_tab');
set(bad_ping_tab_comp.percent_BP,'string',trans_obj.bp_percent2str());

if ~isvalid(axes_panel_comp.bottom_plot)
    axes_panel_comp.bottom_plot=plot(axes_panel_comp.main_axes,nan,'tag','bottom');
end

setappdata(main_figure,'Axes_panel',axes_panel_comp);

if~isempty(idx_bottom)&&~isempty(xdata)&&~isempty(ydata)
    x=linspace(xdata(1),xdata(end),length(xdata));
    %x(isnan(idx_bottom))=[];
    y=nan(size(x));
    y(~isnan(idx_bottom))=ydata(idx_bottom(~isnan(idx_bottom)));
    y(y==numel(ydata))=nan;
    %y(trans_obj.Bottom.Tag==0)=nan;
    set(axes_panel_comp.bottom_plot,'XData',x,'YData',y,'visible',curr_disp.DispBottom);
    set(mini_axes_comp.bottom_plot,'XData',x,'YData',y,'visible',curr_disp.DispBottom);
    
    if isappdata(main_figure,'Secondary_freq')&&curr_disp.DispSecFreqs>0
        secondary_freq=getappdata(main_figure,'Secondary_freq');
        for iax=1:numel(layer.ChannelID)
            idx=(strcmp(layer.ChannelID{iax},{secondary_freq.echoes(:).Tag}));
            bottom_plot_sec=secondary_freq.bottom_plots(idx);
            for i=1:length(bottom_plot_sec)
                [trans_obj_sec,~]=layer.get_trans(layer.ChannelID{iax});
                if isempty(trans_obj_sec)
                    continue;
                end
                xdata_sec=trans_obj_sec.get_transceiver_pings();
                ydata_sec=trans_obj_sec.get_transceiver_samples();
                idx_bottom_sec=trans_obj_sec.Bottom.Sample_idx;
                x_sec=linspace(xdata_sec(1),xdata_sec(end),length(xdata_sec));
                y_sec=nan(size(x_sec));
                y_sec(~isnan(idx_bottom_sec))=ydata_sec(idx_bottom_sec(~isnan(idx_bottom_sec)));
                y_sec(y_sec==numel(ydata_sec))=nan;
            end
            set(bottom_plot_sec,'XData',x_sec,'YData',y_sec,'visible',curr_disp.DispBottom);
        end
    end
else
    set(axes_panel_comp.bottom_plot,'XData',nan,'YData',nan,'visible',curr_disp.DispBottom);
    set(mini_axes_comp.bottom_plot,'XData',nan,'YData',nan,'visible',curr_disp.DispBottom);
end


create_context_menu_bottom(main_figure,axes_panel_comp.bottom_plot);


end
