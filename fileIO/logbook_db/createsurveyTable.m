function createsurveyTable(dbconn)
survey_table=dbconn.fetch('select name FROM sqlite_master WHERE type=''table'' AND name=''survey''');

if isempty(survey_table)
    createsurveyTable_str = ['create table survey ' ...
        '(SurveyName VARCHAR DEFAULT NULL,'...
        'Voyage VARCHAR DEFAULT NULL,'...
        'PRIMARY KEY(Voyage)'...
        'ON CONFLICT REPLACE)'];
    dbconn.exec(createsurveyTable_str);
end