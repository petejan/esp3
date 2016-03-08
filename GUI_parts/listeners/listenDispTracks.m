function listenDispTracks(src,listdata,main_figure)
main_menu=getappdata(main_figure,'main_menu');
set(main_menu.disp_tracks,'checked',listdata.AffectedObject.DispTracks);
toggle_disp_tracks(main_figure);
end