function load_map_tab(main_figure,tab_panel)

switch tab_panel.Type
    case 'uitabgroup'
        map_tab_comp.map_tab=uitab(tab_panel,'Title','Map&Co','backgroundcolor','w');
        tab_menu = uicontextmenu(ancestor(tab_panel,'figure'));
        map_tab_comp.map_tab.UIContextMenu=tab_menu;
        uimenu(tab_menu,'Label','Undock map','Callback',{@undock_map_tab_callback,main_figure,'out_figure'});
    case 'figure'
        map_tab_comp.map_tab=tab_panel;
end

map_tab_comp.ax=axes('Parent',map_tab_comp.map_tab,'Units','normalized','box','on',...
     'OuterPosition',[0 0 1/3 1],'visible','off','NextPlot','add','box','on','tag','nav');
 
 map_tab_comp.ax_hist=axes('Parent',map_tab_comp.map_tab,'Units','normalized',...
    'OuterPosition',[2/3 0 1/3 1],'visible','on','NextPlot','add','box','on','tag','tt_ax');
xlabel(map_tab_comp.ax_hist,'TS(dB)');
grid(map_tab_comp.ax_hist,'on');

map_tab_comp.ax_pos=axes('Parent',map_tab_comp.map_tab,'Units','normalized',...
    'OuterPosition',[1/3 0 1/3 1],'visible','off','NextPlot','add','box','on','tag','st_ax');

map_tab_comp.tracks=[];
map_tab_comp.boat_pos=[];
map_tab_comp.Proj=[];
map_tab_comp.LongLim=[];
map_tab_comp.LatLim=[];

setappdata(main_figure,'Map_tab',map_tab_comp);

update_map_tab(main_figure,'st',1,'histo',1);
end
