
function save_bot_reg_to_db(layer_obj,varargin)
p = inputParser;
addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'bot',1);
addParameter(p,'reg',1);
parse(p,layer_obj,varargin{:});

[path_xml,reg_file_str,bot_file_str]=layer_obj.create_files_str();


for ifile=1:length(reg_file_str)
    if exist(path_xml{ifile},'dir')==0
        mkdir(path_xml{ifile});
    end
    xml_reg_file=fullfile(path_xml{ifile},reg_file_str{ifile});
    xml_bot_file=fullfile(path_xml{ifile},bot_file_str{ifile});
    
    
    dbfile=fullfile(path_xml{ifile},'bot_reg.db');
    if exist(dbfile,'file')==0
        dbconn=sqlite(dbfile,'create');
        
        createbotTable = ['create table bottom ' ...
            '(Filename VARCHAR DEFAULT NULL,'...
            'Version INTEGER DEFAULT 1,'...
            'Bot_XML TEXT DEFAULT NULL,'...
            'Save_time TIME DEFAULT CURRENT_TIMESTAMP,'...
            'PRIMARY KEY(Filename,version)'...
            'ON CONFLICT ABORT)'];
        
        createregTable = ['create table region ' ...
            '(Filename VARCHAR DEFAULT NULL,'...
            'Version NUMERIC DEFAULT 1,'...
            'Reg_XML TEXT DEFAULT NULL,'...
            'Save_time TIME DEFAULT CURRENT_TIMESTAMP,'...
            'PRIMARY KEY(Filename,version)'...
            'ON CONFLICT ABORT)'];
        dbconn.exec(createbotTable);
        dbconn.exec(createregTable);
    else
        dbconn=sqlite(dbfile,'connect');
    end
    
    
    
    
    
    if exist(xml_bot_file,'file')==2&&p.Results.bot>0
        bot_ver = dbconn.fetch(sprintf('select Version from bottom where Filename is "%s"',bot_file_str{ifile}));
        xml_str_bot=fileread(xml_bot_file);
        if isempty(bot_ver)
            bot_ver={0};
        end
        dbconn.insert('bottom',{'Filename'  'Bot_XML' 'Version'},{bot_file_str{ifile} xml_str_bot nanmax(cell2mat(bot_ver))+1});
    end
    
    
    if exist(xml_reg_file,'file')==2&&p.Results.bot>0
        reg_ver = dbconn.fetch(sprintf('select Version from region where Filename is "%s"',reg_file_str{ifile}));
        xml_str_reg=fileread(xml_reg_file);
        if isempty(reg_ver)
            reg_ver={0};
        end
        
        dbconn.insert('region',{'Filename' 'Reg_XML' 'Version'},{reg_file_str{ifile} xml_str_reg nanmax(cell2mat(reg_ver))+1});
    end
    
%     out_bot = dbconn.fetch('select * from bottom')
%     
%     out_reg = dbconn.fetch('select * from region')
    
    
    close(dbconn)
end
end