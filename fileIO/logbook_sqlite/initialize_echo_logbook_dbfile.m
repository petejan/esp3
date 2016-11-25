function initialize_echo_logbook_dbfile(datapath,force_create)

dir_raw=dir(fullfile(datapath,'*.raw'));

dir_asl=dir(fullfile(datapath,'*A'));

list_raw=union({dir_raw(:).name},{dir_asl(:).name});

nb_files_raw=length(list_raw);

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

createlogbookTable = ['create table logbook ' ...
    '(Filename CHAR DEFAULT NULL,'...
    'Snapshot NUMERIC DEFAULT 1,'...
    'Stratum VARCHAR DEFAULT NULL,'...
    'Transect NUMERIC DEFAULT 1,'...
    'StartTime TIME,'...%yyyy-mm-dd HH:MM:SS
    'EndTime TIME,'...
    'Comment TEXT DEFAULT NULL,'...
    'PRIMARY KEY(Filename,StartTime) ON CONFLICT REPLACE,'...
    'UNIQUE(Filename,EndTime) ON CONFLICT REPLACE,'...
    'CHECK (EndTime>=StartTime))'];

createsurveyTable = ['create table survey ' ...
    '(SurveyName VARCHAR DEFAULT NULL,'...
    'Voyage VARCHAR DEFAULT NULL,'...
    'PRIMARY KEY(Voyage)'...
    'ON CONFLICT REPLACE)'];

dbconn.exec(createlogbookTable);
dbconn.exec(createsurveyTable);

dbconn.insert('survey',{'SurveyName' 'Voyage' },{'' ''});
survdata_temp=survey_data_cl();

if force_create==0;
    for i=1:nb_files_raw
        fprintf('Getting Start and End Date from file %s (%i/%i)\n',list_raw{i},i,nb_files_raw);
        [start_date,end_date]=start_end_time_from_file(fullfile(datapath,list_raw{i}));
        survdata_temp.surv_data_to_logbook_db(dbconn,list_raw{i},'StartTime',start_date,'EndTime',end_date);
    end
end
close(dbconn);






end