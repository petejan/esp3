function load_bot_regs(layer,varargin)
p = inputParser;

addRequired(p,'layer',@(obj) isa(obj,'layer_cl'));
addParameter(p,'bot_ver',1);
addParameter(p,'reg_ver',1);
addParameter(p,'IDs',[]);

parse(p,layer,varargin{:});

[path_xml,reg_file_str,bot_file_str,~]=layer.create_files_str();

if p.Results.bot_ver>0

    
    if exist(fullfile(path_xml,bot_file_str),'file')>0
        layer.add_bottoms_from_bot_xml(fullfile(path_xml,bot_file_str));
    else
        [t_0,t_1]=get_start_end_time_str(bot_file_str);
        bot_file_list=ls(fullfile(path_xml,'b*.xml'));
        idx_file=[];
        for ifile=1:size(bot_file_list,1)
            [t_0_temp,t_1_temp]=get_start_end_time_str(bot_file_list(ifile,:));
            if (t_0_temp<=t_0& t_1_temp>=t_1)|(t_0_temp<=t_1& t_1_temp>=t_1) | (t_1_temp>=t_0& t_0_temp<=t_0)| (t_0_temp>=t_0& t_1_temp<=t_1)
                idx_file=[idx_file ifile];
            end
        end
        
        if isempty(idx_file)
            warning('No bottom file for this layer');
        else
            layer.add_bottoms_from_bot_xml(fullfile(path_xml,bot_file_list(idx_file(1),:)));
        end
        
    end
end


if p.Results.reg_ver>0
    
    for uui=1:length(layer.Frequencies)
        layer.Transceivers(uui).rm_all_region();
    end
    
    if exist(fullfile(path_xml,reg_file_str),'file')>0
        layer.add_regions_from_reg_xml(fullfile(path_xml,reg_file_str),p.Results.IDs);
    else
        [t_0,t_1]=get_start_end_time_str(reg_file_str);
        reg_file_list=ls(fullfile(path_xml,'r*.xml'));
        idx_file=[];
        for ifile=1:size(reg_file_list,1)
            [t_0_temp,t_1_temp]=get_start_end_time_str(reg_file_list(ifile,:));
            if (t_0_temp<=t_0&& t_1_temp>=t_1)||(t_0_temp<=t_1&& t_1_temp>=t_1) || (t_1_temp>=t_0&& t_0_temp<=t_0)|| (t_0_temp>=t_0&& t_1_temp<=t_1)
                idx_file=[idx_file ifile];
            end
        end
        
        if isempty(idx_file)
            warning('No region file for this layer');
        else
            layer.add_regions_from_reg_xml(fullfile(path_xml,reg_file_list(idx_file(1),:)),p.Results.IDs);
        end
        
    end
end
end

function [t_0,t_1]=get_start_end_time_str(xml_str)
tmp_str=strrep(xml_str,'_',' ');
tmp=textscan(tmp_str,'%s %s %s.xml');
if ~isempty(tmp{2})&&~isempty(tmp{3})
    t_0=datenum(tmp{2},'yyyymmddHHMMSS');
    t_1=datenum(tmp{3},'yyyymmddHHMMSS');
else
    t_0=nan;
    t_1=nan;
end
end