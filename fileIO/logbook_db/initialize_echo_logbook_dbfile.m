function initialize_echo_logbook_dbfile(datapath,force_create)

[list_raw,ftypes]=list_ac_files(datapath,0);

db_file=fullfile(datapath,'echo_logbook.db');
if exist(db_file,'file')==2
    return;
end

xml_file=fullfile(datapath,'echo_logbook.xml');
if exist(xml_file,'file')==2&&force_create==0
    xml_logbook_to_db(xml_file);
    return;
end

csv_file='echo_logbook.csv';
if exist(fullfile(datapath,csv_file),'file')==2&&force_create==0
    csv_logbook_to_db(datapath,csv_file,'','');
    return;
end
disp('Creating .db logbook file, this might take a couple minutes...');
dbconn=sqlite(db_file,'create');

createlogbookTable(dbconn);
createsurveyTable(dbconn);
creategpsTable(dbconn);

dbconn.insert('survey',{'SurveyName' 'Voyage' },{'' ''});

if force_create==0
    add_files_to_db(datapath,list_raw,ftypes,dbconn,[])
end
close(dbconn);



end