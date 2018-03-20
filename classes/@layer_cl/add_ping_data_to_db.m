
function add_ping_data_to_db(layers_obj)

for ilay=1:length(layers_obj)
    
        itrans=1;
        trans_obj=layers_obj(ilay).Transceivers(itrans);
        freq=layers_obj(ilay).Frequencies(itrans);
        fileID_vec=trans_obj.get_fileID();
        
        gps_data_obj=trans_obj.GPSDataPing;
        bot_range=trans_obj.get_bottom_range();
        
        [~,id_keep]=gps_data_obj.clean_gps_track();
        id_keep=intersect(id_keep,find(~isnan(gps_data_obj.Lat)));
        
        if~isdeployed()
            fprintf('Number of pings: %.0f\nReduced Number of point in navigation:%.0f\n',numel(gps_data_obj.Time),numel(id_keep))
        end
        
        for ip=1:length(layers_obj(ilay).Filename)
            idx_pings=find(fileID_vec==ip);
            id_keep_f=intersect(id_keep,idx_pings);
            [pathtofile,fileOri,extN]=fileparts(layers_obj(ilay).Filename{ip});
            
            fileN=fullfile(pathtofile,'echo_logbook.db');
            
            if exist(fileN,'file')==0
                initialize_echo_logbook_dbfile(pathtofile,0);
            end
            
            if ~any(gps_data_obj.Lat~=0)
                return;
            end

            dbconn=sqlite(fileN,'connect');
            createPingTable(dbconn);
            time_cell=cellfun(@(x) datestr(x,'yyyy-mm-dd HH:MM:SS'),(num2cell(gps_data_obj.Time(id_keep_f))),'UniformOutput',0);
            colnames={'Filename' 'Ping_number' 'Frequency' 'Lat' 'Long' 'Time' 'Depth'};
            
            t=table(...
                repmat({[fileOri extN]},numel(id_keep_f),1),id_keep_f-idx_pings(1)+1,repmat(freq,numel(id_keep_f),1),gps_data_obj.Lat(id_keep_f),gps_data_obj.Long(id_keep_f),time_cell,bot_range(id_keep_f)',...
                'VariableNames',colnames);
            dbconn.insert('ping_data',colnames,t);
            close(dbconn);
            
        end
        

end
end