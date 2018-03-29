function [start_time,end_time]=get_time_bound_files(layer_obj)

start_time=zeros(1,length(layer_obj.Filename));
end_time=ones(1,length(layer_obj.Filename));

for ifi=1:length(layer_obj.Filename)
    try
        if ~isempty(layer_obj.Transceivers)
            idx_ping_start=find(layer_obj.Transceivers(1).Data.FileId==ifi,1,'first');
            idx_ping_end=find(layer_obj.Transceivers(1).Data.FileId==ifi,1,'last');
            start_time(ifi)=layer_obj.Transceivers(1).Time(idx_ping_start);
            end_time(ifi)=layer_obj.Transceivers(1).Time(idx_ping_end);
        else
            [start_time(ifi),end_time(ifi),~]=start_end_time_from_file(layer_obj.Filename{ifi});
        end
    catch
        [start_time(ifi),end_time(ifi),~]=start_end_time_from_file(layer_obj.Filename{ifi});
    end
end

end