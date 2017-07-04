function display_st_or_track_pos(main_figure,ax,disp_var)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
trans_obj=layer.get_trans(curr_disp.Freq);

if isempty(trans_obj)
    return;
end
ST = trans_obj.ST;
if isempty(ST)
    c=[];
    y=[];
    x=[];
else
    switch disp_var
        case 'st'
            c = ST.TS_uncomp;
            y=ST.Angle_minor_axis;
            x=ST.Angle_major_axis;
        case 'tracks'
            tracks = trans_obj.Tracks;
            
            if isempty(tracks)
                return;
            end
            for k=1:length(tracks.target_id)
                idx_targets=tracks.target_id{k};
                c=[c ST.TS_comp(idx_targets)];
                y=[y ST.Angle_minor_axis(idx_targets)];
                x=[x ST.Angle_major_axis(idx_targets)];
            end
    end
end

obj=findobj(ax,'Tag','scat_data');
delete(obj);

cax=curr_disp.getCaxField('sp');
c(c<cax(1))=nan;
scat_plot=scatter(ax,x,y,10,c,'filled','Tag','scat_data');
uistack(scat_plot,'bottom');




end