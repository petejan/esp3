function load_multi_freq_disp_tab(main_figure,tab_panel)

switch tab_panel.Type
    case 'uitabgroup'
        multi_freq_disp_tab_comp.multi_freq_disp_tab=new_echo_tab(main_figure,tab_panel,'Title','Sv(f)','UiContextMenuName','multi_freq');
    case 'figure'
        multi_freq_disp_tab_comp.multi_freq_disp_tab=tab_panel;
end

multi_freq_disp_tab_comp.ax=axes('Parent',multi_freq_disp_tab_comp.multi_freq_disp_tab,'Units','normalized','box','on',...
     'OuterPosition',[0 0 2/3 1],'visible','off','NextPlot','add','box','on');
 multi_freq_disp_tab_comp.ax.XLabel.String='kHz';
 multi_freq_disp_tab_comp.ax.YLabel.String='dB';

 
setappdata(main_figure,'multi_freq_disp_tab',multi_freq_disp_tab_comp);

update_multi_freq_disp_tab(main_figure);

end
