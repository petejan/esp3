function [start_time,end_time]=get_time_bound_files(layer_obj)

   start_time=zeros(1,length(layer_obj.Filename));
   end_time=ones(1,length(layer_obj.Filename));
   
   for ifi=1:length(layer_obj.Filename)
       if ~isempty(layer_obj.Transceivers)
           idx_ping_start=find(layer_obj.Transceivers(1).Data.FileId==ifi,1,'first');
           idx_ping_end=find(layer_obj.Transceivers(1).Data.FileId==ifi,1,'last');
           start_time(ifi)=layer_obj.Transceivers(1).Time(idx_ping_start);
           end_time(ifi)=layer_obj.Transceivers(1).Time(idx_ping_end);
       elseif ~isempty(layer_obj.GPSData.Time)&&length(layer_obj.Filename)==1
           start_time(ifi)=layer_obj.GPSData.Time(1);
           end_time(ifi)=layer_obj.GPSData.Time(end);
       end
   end

end