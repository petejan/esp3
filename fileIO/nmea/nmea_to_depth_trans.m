
function [depth_trans,depth_time]=nmea_to_depth_trans(NMEA_string_cell,NMEA_time,idx_NMEA)

depth_trans=zeros(1,length(idx_NMEA));
depth_time=zeros(1,length(idx_NMEA));
id=0;
for iiii=idx_NMEA(:)'
    %for iiii=1:length(NMEA_string_cell)
    curr_message=NMEA_string_cell{iiii};
    curr_message(isspace(curr_message))=' ';
     try
         [nmea,nmea_type]=parseNMEA(curr_message);
   
        switch nmea_type
            case 'depth'
                id=id+1;
                depth_trans(id)=-nmea.depth;
                depth_time(id)=NMEA_time(iiii);
        end       
     catch
          fprintf('Invalid NMEA message: %s\n',curr_message);
    end
    
end
