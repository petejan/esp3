function [dbconn,db_type]=connect_to_db(ac_db_filename,varargin)

p = inputParser;

addRequired(p,'ac_db_filename',@ischar);
addParameter(p,'db_type','sqlite',@ischar);
addParameter(p,'user',getenv('USERNAME'),@ischar);
addParameter(p,'pwd','',@ischar);
parse(p,ac_db_filename,varargin{:});

dbconn=[];
%db_type='';
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
            dbconn=sqlite(ac_db_filename,'connect');
        end
    case 'PostgreSQL'
        conn=strsplit(ac_db_filename,':');       
        dbconn = database(conn{2},p.Results.user,p.Results.pwd, ...
            'Vendor','PostgreSQL', ...
            'Server',conn{1});
        sql_query=sprintf('SET search_path = %s',conn{3});
        dbconn.exec(sql_query);
end


