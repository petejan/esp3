function load_secondary_freq_win(main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
if curr_disp.DispSecFreqs<=0
    return;
end

if isappdata(main_figure,'Secondary_freq')
    secondary_freq=getappdata(main_figure,'Secondary_freq');    
    delete(secondary_freq.axes);
    delete(secondary_freq.echoes);
else
    secondary_freq.fig=new_echo_figure(main_figure,'Position',[0 0.1 1 0.8],'Units','normalized',...
        'Name','All Channels','CloseRequestFcn',@rm_Secondary_freq,'Tag','Secondary_freq_win');
end

curr_disp=getappdata(main_figure,'Curr_disp');

nb_chan=numel(curr_disp.SecChannelIDs);
secondary_freq.axes=gobjects(1,nb_chan);
secondary_freq.echoes=gobjects(1,nb_chan);
secondary_freq.echoes_bt=gobjects(1,nb_chan);
secondary_freq.bottom_plots=gobjects(1,nb_chan);
secondary_freq.names=gobjects(1,nb_chan);

axes_panel_comp=getappdata(main_figure,'Axes_panel');
for i=1:nb_chan
    secondary_freq.axes(i)=axes(secondary_freq.fig,'Units','Normalized','Position',[0 1-i/nb_chan 1 1/nb_chan],...
        'nextplot','add','Layer','top','XLimMode','manual','YLimMode','manual','LineWidth',1.0,'TickLength',[0.005 0.005],'XGrid','on','YGrid','off');
    secondary_freq.echoes(i)=image(1,1,1,'Parent',secondary_freq.axes(i),'CDataMapping','scaled','Tag',curr_disp.SecChannelIDs{i});
    secondary_freq.echoes_bt(i)=image(1,1,1,'Parent',secondary_freq.axes(i),'Tag','bad_transmits','AlphaData',0);
    secondary_freq.names(i)=text(secondary_freq.axes(i),10,15,sprintf('%.0fkHz',curr_disp.SecFreqs(i)/1e3),'Units','Pixel','Fontweight','Bold','Fontsize',16,'ButtonDownFcn',{@change_cid,main_figure},'Tag',curr_disp.SecChannelIDs{i});
    secondary_freq.bottom_plots(i)=plot(secondary_freq.axes(i),nan,nan,'tag','bottom');
    secondary_freq.axes(i).XTick=axes_panel_comp.main_axes.XTick;
end
set(secondary_freq.axes,'GridLineStyle',axes_panel_comp.main_axes.GridLineStyle,...
    'XTick',axes_panel_comp.main_axes.XTick,...
    'YTick',axes_panel_comp.main_axes.YTick);
secondary_freq.link_props=linkprop([secondary_freq.axes axes_panel_comp.main_axes],{'YColor','XColor','GridLineStyle','XTick','Color','Clim','GridColor','MinorGridColor','YDir'});

setappdata(main_figure,'Secondary_freq',secondary_freq);
update_secondary_freq_win(main_figure);

end

function  change_cid(src,evt,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
curr_disp.ChannelID=src.Tag;
end

function rm_Secondary_freq(src,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
curr_disp.DispSecFreqs=0;

end