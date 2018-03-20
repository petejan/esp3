function load_st_tracks_tab(main_figure,tab_panel)

switch tab_panel.Type
    case 'uitabgroup'
        st_tracks_tab_comp.st_tracks_tab=new_echo_tab(main_figure,tab_panel,'Title','ST&tracks','UiContextMenuName','st_tracks');
    case 'figure'
        st_tracks_tab_comp.st_tracks_tab=tab_panel;
end

 st_tracks_tab_comp.ax_hist=axes('Parent',st_tracks_tab_comp.st_tracks_tab,'Units','normalized',...
     'OuterPosition',[1/2 0 1/2 1],'visible','on','NextPlot','add','box','on','tag','tt_ax');
 xlabel(st_tracks_tab_comp.ax_hist,'TS(dB)');
 ylabel(st_tracks_tab_comp.ax_hist,'PDF');
 grid(st_tracks_tab_comp.ax_hist,'on');

st_tracks_tab_comp.ax_pos=axes('Parent',st_tracks_tab_comp.st_tracks_tab,'Units','normalized',...
    'OuterPosition',[0 0 1/2 1],'visible','off','box','on','tag','st_ax');

st_tracks_tab_comp.tracks=[];
st_tracks_tab_comp.boat_pos=[];
st_tracks_tab_comp.Proj=[];
st_tracks_tab_comp.LongLim=[];
st_tracks_tab_comp.LatLim=[];

setappdata(main_figure,'ST_Tracks',st_tracks_tab_comp);

update_st_tracks_tab(main_figure,'st',1,'histo',1);
end
