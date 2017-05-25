function createlogbookTable(dbconn)

logbook_table=dbconn.fetch('select name FROM sqlite_master WHERE type=''table'' AND name=''logbook''');

if isempty(logbook_table)
    createlogbookTable_str = ['create table logbook ' ...
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
    dbconn.exec(createlogbookTable_str);
    
end