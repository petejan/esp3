function [ver_reg_loaded,comment]=create_reg_xml_from_db(layer_obj,varargin)

p = inputParser;

addRequired(p,'layer_obj',@(obj) isa(obj,'layer_cl'));
addParameter(p,'reg_ver',-1);

parse(p,layer_obj,varargin{:});

ver_reg_loaded=p.Results.reg_ver;
comment='';

if isempty(p.Results.reg_ver)
    return;
end
if p.Results.reg_ver<0
    return;
end

[path_xml,reg_file_str,~]=layer_obj.create_files_str();


for ifile=1:length(path_xml)
    if exist(path_xml{ifile},'dir')==0
        mkdir(path_xml{ifile});
    end
    
    dbfile=fullfile(path_xml{ifile},'bot_reg.db');
    if exist(dbfile,'file')==0
        ver_reg_loaded=-1;
        warning('Region and Bottom database file %s does not exist, we''ll get the Region from existing xml.',dbfile);
        continue;
    end
    dbconn=sqlite(dbfile,'connect');
    
    if p.Results.reg_ver>=0
        reg_xml_version = dbconn.fetch(sprintf('select reg_XML,Version,Comment from region where Filename is "%s"',reg_file_str{ifile}));
        if isempty(reg_xml_version)
            ver_reg_loaded=-1;
            warning('No Region in database for file %s, we''ll get the region from existing xml if there is one.',reg_file_str{ifile});
            continue;
        end
        
        ver_num=cell2mat(reg_xml_version(:,2));
        
        if ver_reg_loaded==0
            [ver_reg_loaded,idx_xml]=nanmax(ver_num);
        else
            idx_xml=find(ver_num<=p.Results.reg_ver,1,'last');
            ver_reg_loaded=ver_num(idx_xml);
        end
        comment=reg_xml_version{idx_xml,3};
        
        xml_str=reg_xml_version{idx_xml,1};
        fid = fopen(fullfile(path_xml{ifile},reg_file_str{ifile}),'w+');
        fprintf(fid,'%s', xml_str);
        fclose(fid);
    end
    
    
end


