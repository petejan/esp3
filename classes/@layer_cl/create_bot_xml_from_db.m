function ver_bot_loaded=create_bot_xml_from_db(layer_obj,varargin)

p = inputParser;

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'bot_ver',-1);

parse(p,layer_obj,varargin{:});

ver_bot_loaded=p.Results.bot_ver;

if isempty(p.Results.bot_ver)
    return;
end
if p.Results.bot_ver<0
    return;
end

[path_xml,~,bot_file_str]=layer_obj.create_files_str();


for ifile=1:length(path_xml)
    if exist(path_xml{ifile},'dir')==0
        mkdir(path_xml{ifile});
    end
    
    dbfile=fullfile(path_xml{ifile},'bot_reg.db');
    if exist(dbfile,'file')==0
        ver_bot_loaded=-1;
%         warning('Region and Bottom database file %s does not exist, we''ll get the bottom from existing xml.',dbfile);
        continue;
    end
    dbconn=sqlite(dbfile,'connect');
    
    if p.Results.bot_ver>=0
        bot_xml_version = dbconn.fetch(sprintf('select bot_XML,Version from bottom where Filename is "%s"',bot_file_str{ifile}));
        if isempty(bot_xml_version)
            ver_bot_loaded=-1;
%             warning('No bottom in database for file %s, we''ll get the bottom from existing xml if there is one.',bot_file_str{ifile});
            continue;
        end
        
        ver_num=cell2mat(bot_xml_version(:,2));
        
        if p.Results.bot_ver==0
            [ver_bot_loaded,idx_xml]=nanmax(ver_num);
        else
            idx_xml=find(ver_num<=p.Results.bot_ver,1,'last');
            ver_bot_loaded=ver_num(idx_xml);
        end
        
        xml_str=bot_xml_version{idx_xml,1};
        fid = fopen(fullfile(path_xml{ifile},bot_file_str{ifile}),'w+');
        fprintf(fid,'%s', xml_str);
        fclose(fid);
    end
    
    
end


