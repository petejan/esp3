function createlogbookTable(dbconn)

logbook_table=dbconn.fetch('select name FROM sqlite_master WHERE type=''table'' AND name=''logbook''');

if isempty(logbook_table)
    createlogbookTable_str = ['create table logbook ' ...
        '(Filename CHAR DEFAULT NULL,'...
        'Snapshot NUMERIC DEFAULT 0,'...
        'Stratum VARCHAR DEFAULT NULL,'...
        'Type VARCHAR DEFAULT NULL,'...
        'Transect NUMERIC DEFAULT 0,'...
        'StartTime TIME,'...%yyyy-mm-dd HH:MM:SS
        'EndTime TIME,'...
        'Comment TEXT DEFAULT NULL,'...
        'PRIMARY KEY(Filename,StartTime) ON CONFLICT REPLACE,'...
        'UNIQUE(Filename,EndTime) ON CONFLICT REPLACE,'...
        'CHECK (EndTime>=StartTime))'];
    dbconn.exec(createlogbookTable_str);
    
else
    isthereatypecolumn=dbconn.fetch('select sql FROM sqlite_master WHERE type=''table'' AND name=''logbook''');
    if ~contains(isthereatypecolumn{1},'Type')
        dbconn.exec(['ALTER TABLE logbook '...
            'ADD Type VARCHAR DEFAULT ""']);
    end 
end