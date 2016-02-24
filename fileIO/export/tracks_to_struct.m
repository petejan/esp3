function track_struct=tracks_to_struct(ST,tracks)

nb_tracks=length(tracks.target_id);
fields=fieldnames(ST);
%nb_st=nansum(cellfun(@length,tracks.target_id));
st_num=0;
for i=1:nb_tracks
    nb_st_track=length(tracks.target_id{i});
    track_struct.Track_num(st_num+1:st_num+nb_st_track,1)=i;
    for ifd=1:length(fields)
        if ~strcmp(fields{ifd},'nb_valid_targets')
            track_struct.(fields{ifd})(st_num+1:st_num+nb_st_track,1)=ST.(fields{ifd})(tracks.target_id{i});
        end
    end
    st_num=st_num+nb_st_track;
end
end


