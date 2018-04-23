function [dbconn,db_type]=connect_to_db(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'db_type','sqlite',@ischar);
addParameter(p,'user',getenv('USERNAME'),@ischar);
addParameter(p,'pwd','',@ischar);
parse(p,ac_db_filename,varargin{:});

dbconn=[];

prop.DataReturnFormat = 'table';
setdbprefs(prop);

if isfile(ac_db_filename)
    db_type='SQlite';
else
    db_type='PostgreSQL';
end

switch db_type
    case 'SQlite'
        try
            user = '';
            password = '';
            driver = 'org.sqlite.JDBC';
            protocol = 'jdbc';
            subprotocol = 'sqlite';
            resource = ac_db_filename;
            url = strjoin({protocol, subprotocol, resource}, ':');
            dbconn = database(ac_db_filename, user, password, driver, url);
        catch
            warning('connect_to_db:cannot use Sqlite JDBC driver! Some functions might not work...');
            if isfile(ac_db_filename)
                dbconn=sqlite(ac_db_filename,'connect');
            end
        end
    case 'PostgreSQL'
        try
            conn=strsplit(ac_db_filename,':');
            dbconn = database(conn{2},p.Results.user,p.Results.pwd, ...
                'Vendor','PostgreSQL', ...
                'Server',conn{1});
            if ~isempty(strfind(dbconn.Message,'failed'))
                dbconn=[];
                db_type='';
            end
            sql_query=sprintf('SET search_path = %s',conn{3});
            dbconn.exec(sql_query);
        catch
            dbconn=[];
            db_type='';
        end

end


