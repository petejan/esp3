
function add_ping_data_to_db(layers_obj)

for ilay=1:length(layers_obj)
    
    
    for itrans=1:numel(layers_obj(ilay).Frequencies)
        trans_obj=layers_obj(ilay).Transceivers(itrans);
        freq=layers_obj(ilay).Frequencies(itrans);
        fileID_vec=trans_obj.get_fileID();
        
        
        for ip=1:length(layers_obj(ilay).Filename)
            idx_pings=find(fileID_vec==ip);
            [pathtofile,fileOri,extN]=fileparts(layers_obj(ilay).Filename{ip});
            
            fileN=fullfile(pathtofile,'echo_logbook.db');
            
            if exist(fileN,'file')==0
                initialize_echo_logbook_dbfile(pathtofile,0);
            end
            
            gps_data_obj=trans_obj.GPSDataPing;
            bot_range=trans_obj.get_bottom_range(idx_pings);
            
            dbconn=sqlite(fileN,'connect');
            createPingTable(dbconn);
            
            ping_num=1:numel(idx_pings);
            if ~isempty(trans_obj.Time)
                time_obj=trans_obj.Time(idx_pings);
            else
                gps_data_obj.Time(idx_pings);
            end
            
            for iping=1:numel(ping_num)
                dbconn.insert('ping_data',{'Filename' 'Ping_number' 'Frequency' 'Lat' 'Long' 'Time' 'Depth'},...
                    {[fileOri extN] ping_num(idx_pings(iping)) freq gps_data_obj.Lat(idx_pings(iping)) gps_data_obj.Long(idx_pings(iping)) datestr(time_obj(iping),'yyyy-mm-dd HH:MM:SS') bot_range(iping)});
            end
            close(dbconn);
            
        end
        
    end
end
end