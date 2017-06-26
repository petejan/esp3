function remove_tracks_cback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj=layer.get_trans(curr_disp.Freq);
trans_obj.rm_tracks;

display_tracks(main_figure);
end