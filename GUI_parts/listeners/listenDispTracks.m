function listenDispTracks(src,listdata,main_figure)
display_tab_comp=getappdata(main_figure,'Display_tab');
set(display_tab_comp.disp_tracks,'value',strcmpi(listdata.AffectedObject.DispTracks,'on'));
toggle_disp_tracks(main_figure);
end