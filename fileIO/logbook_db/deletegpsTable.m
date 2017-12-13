function deletegpsTable(dbconn)
gps_data_table=dbconn.fetch('select sql FROM sqlite_master WHERE type=''table'' AND name=''gps_data''');

if ~isempty(gps_data_table)
    delgpsTable_str = 'DROP table gps_data ';
    dbconn.exec(delgpsTable_str);
end


