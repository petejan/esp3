function nb_pings=get_nb_pings_per_file(data_obj)

files_id=unique(data_obj.FileId);

nb_pings=nan(1,length(files_id));

for fi=1:length(files_id)
    nb_pings(fi)=nansum(data_obj.FileId==files_id(fi));
end

end