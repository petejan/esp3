%% add_gps_data_to_db.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |layers_obj|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-05-25: first version (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function add_gps_data_to_db(layers_obj)

for ilay=1:length(layers_obj)
    
    [start_time,end_time]=get_time_bound_files(layers_obj(ilay));
    
    for ip=1:length(start_time)
        [pathtofile,fileOri,extN]=fileparts(layers_obj(ilay).Filename{ip});

        fileN=fullfile(pathtofile,'echo_logbook.db');
        
        if exist(fileN,'file')==0
            initialize_echo_logbook_dbfile(pathtofile,0);
        end
        
        [~,idx_freq]=nanmin(layers_obj(ilay).Frequencies);
        trans_obj=layers_obj(ilay).Transceivers(idx_freq);    
        gps_data_obj=trans_obj.GPSDataPing;
        bot_range=trans_obj.get_bottom_range();
        
        idx_t=gps_data_obj.Time>=start_time(ip)&gps_data_obj.Time<=end_time(ip);
        dbconn=sqlite(fileN,'connect');
        %files_db=dbconn.fetch('select Filename from gps_data');
        %         if ~any(strcmp([fileOri extN],files_db))
        creategpsTable(dbconn);

        time_str=datestr(gps_data_obj.Time(idx_t),'yyyymmddHHMMSSFFF ')';
        time_str=time_str(:)';
%         longlat_str=['LINESTRING(' sprintf('%.6f %.6f,',kron(gps_data_obj.Long(idx_t)', [1 0]) + kron(gps_data_obj.Lat(idx_t)', [0 1])) ')'];
        dbconn.insert('gps_data',{'Filename' 'Lat' 'Long' 'Time' 'Depth'},...
            {[fileOri extN] sprintf('%.6f ',gps_data_obj.Lat(idx_t)) sprintf('%.6f ',gps_data_obj.Long(idx_t)) time_str sprintf('%.2f ',bot_range(idx_t))});
        %         end
        close(dbconn);
        
    end
    
end

end