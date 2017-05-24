%% load_bot_reg_data_fig_from_db.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function load_bot_reg_data_fig_from_db(main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer) 
    return;
else
    [path_xml,reg_bot_file_str,bot_file_str]=layer.create_files_str();   
end

version_bot=[];
version_reg=[];
%comments_reg={};

curr_disp=getappdata(main_figure,'Curr_disp');
[idx_freq,~]=layer.find_freq_idx(curr_disp.Freq);
[bot_ver_curr,reg_ver_curr]=layer.Transceivers(idx_freq).get_loaded_bot_reg_version();

for ip=1:length(path_xml)
    db_file=fullfile(path_xml{ip},'bot_reg.db');
    
    if exist(db_file,'file')==0
        initialize_reg_bot_db(db_file);
        continue;
    end
    
    dbconn=sqlite(db_file,'connect');
    
    regions_db_temp=dbconn.fetch(sprintf('select Version,Comment from region where Filename is "%s" order by datetime(Save_time)',reg_bot_file_str{ip}));
    bottom_db_temp=dbconn.fetch(sprintf('select Version from bottom where Filename is "%s" order by datetime(Save_time)',bot_file_str{ip}));
    dbconn.close();
    
    if ~isempty(regions_db_temp)
        [version_reg,~,~]=union(version_reg,cell2mat(regions_db_temp(:,1)),'stable');
    end
    
    if ~isempty(bottom_db_temp)
        [version_bot,~,~]=union(version_bot,cell2mat(bottom_db_temp(:,1)),'stable');
    end
end

if isempty(version_reg)
    reg_str='--';
    id_reg=1;
else
    reg_str=num2cell(version_reg);
    id_reg=find(version_reg==reg_ver_curr);
    if isempty(id_reg)
        id_reg=1;
    end
end

if isempty(version_bot)
    bot_str='--';
    id_bot=1;
else
    bot_str=num2cell(version_bot);
    id_bot=find(version_bot==bot_ver_curr);
    if isempty(id_bot)
        id_bot=1;
    end
end

reg_bot_data_fig=new_echo_figure(main_figure,...
    'Units','pixels',...
    'Position',[0 0 400 100],...
    'Resize','off',...
    'MenuBar','none',...
    'Name','Region Bottom Version','Tag','reg_bot_ver','WindowStyle','modal');

uicontrol(reg_bot_data_fig,'style','text','string','Choose the bottom/region version you want to load','units','Normalized','Position',[0.05 0.7 0.9 0.25],'Fontsize',14);
text_bot=uicontrol(reg_bot_data_fig,'style','text','string','Bottom Version','units','Normalized','Position',[0.05 0.3 0.25 0.2]);
bot_ver=uicontrol(reg_bot_data_fig,'style','popup','string',bot_str,'units','Normalized','Position',[0.3 0.3 0.1 0.2],'Value',id_bot,...
    'Callback',{@import_bot_cback,main_figure});
text_reg=uicontrol(reg_bot_data_fig,'style','text','string','Region Version','units','Normalized','Position',[0.5 0.3 0.25 0.2]);
reg_ver=uicontrol(reg_bot_data_fig,'style','popup','string',reg_str,'units','Normalized','Position',[0.6 0.3 0.1 0.2],'Value',id_reg,...
    'Callback',{@import_reg_cback,main_figure});

align([text_bot bot_ver text_reg reg_ver],'Distribute','Center');
movegui(reg_bot_data_fig,'center');
end

function import_bot_cback(src,~,main_figure)
if strcmp(src.String,'--')
    return;
end

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

war_str=('WARNING: This will replace currently defined Bottom?');


choice = questdlg(war_str, ...
    'Load XML',...
    'Yes','No', ...
    'No');
% Handle response
switch choice
    case 'No'
        return;
end

id=get(src,'value');
str=get(src,'string');

layer.load_bot_regs('bot_ver',str2double(str(id)),'reg_ver',[]);
disp('Bottom and regions imported');

display_bottom(main_figure);

set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
order_stacks_fig(main_figure);

end


function import_reg_cback(src,~,main_figure)

if strcmp(src.String,'--')
    return;
end
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

if isempty(layer)
    return;
end

war_str=('WARNING: This will replace currently defined Regions?');


choice = questdlg(war_str, ...
    'Load XML',...
    'Yes','No', ...
    'No');
% Handle response
switch choice
    case 'No'
        return;
end

id=get(src,'value');
str=get(src,'string');

layer.load_bot_regs('bot_ver',[],'reg_ver',str2double(str(id)));
display_regions(main_figure,'both');
trans_obj=layer.get_trans(curr_disp.Freq);
curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();

set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
order_stacks_fig(main_figure);

end

