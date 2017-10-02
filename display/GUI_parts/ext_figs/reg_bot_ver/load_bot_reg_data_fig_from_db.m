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
% 
% version_bot=[];
% version_reg=[];
%comments_reg={};

% curr_disp=getappdata(main_figure,'Curr_disp');
% [idx_freq,~]=layer.find_freq_idx(curr_disp.Freq);
% [bot_ver_curr,reg_ver_curr]=layer.Transceivers(idx_freq).get_loaded_bot_reg_version();

for ip=1:length(path_xml)
    db_file=fullfile(path_xml{ip},'bot_reg.db');
    
    if exist(db_file,'file')==0
        initialize_reg_bot_db(db_file);
        continue;
    end
    
    dbconn=sqlite(db_file,'connect');
    
    regions_db_temp=dbconn.fetch(sprintf('select Version,Comment,Save_time from region where Filename is "%s" order by datetime(Save_time)',reg_bot_file_str{ip}));
    bottom_db_temp=dbconn.fetch(sprintf('select Version,Comment,Save_time from bottom where Filename is "%s" order by datetime(Save_time)',bot_file_str{ip}));
    dbconn.close();
    
%     if ~isempty(regions_db_temp)
%         [version_reg,~,~]=union(version_reg,cell2mat(regions_db_temp(:,1)),'stable');
%     end
%     
%     if ~isempty(bottom_db_temp)
%         [version_bot,~,~]=union(version_bot,cell2mat(bottom_db_temp(:,1)),'stable');
%     end
end
% 
% if isempty(version_reg)
%     id_reg=1;
% else
%     id_reg=find(version_reg==reg_ver_curr);
%     if isempty(id_reg)
%         id_reg=1;
%     end
% end
% 
% if isempty(version_bot)
%     id_bot=1;
% else
%     id_bot=find(version_bot==bot_ver_curr);
%     if isempty(id_bot)
%         id_bot=1;
%     end
% end


if ~isempty(bottom_db_temp)
    botDataSummary(:,1)=bottom_db_temp(:,1);
    botDataSummary(:,2)=bottom_db_temp(:,2);
    botDataSummary(:,3)=bottom_db_temp(:,3);
else
    botDataSummary=[];
end

if ~isempty(regions_db_temp)
    regDataSummary(:,1)=regions_db_temp(:,1);
    regDataSummary(:,2)=regions_db_temp(:,2);
    regDataSummary(:,3)=regions_db_temp(:,3);
else
    regDataSummary=[];
end


reg_bot_data_fig=new_echo_figure(main_figure,...
    'Units','pixels',...
    'Position',[0 0 600 300],...
    'Resize','off',...
    'MenuBar','none',...
    'Name','Region Bottom Version','Tag','reg_bot_ver','WindowStyle','modal');


% Column names and column format
columnname = {'Version' 'Comment' 'Date'};
columnformat = {'numeric' 'char','char'};

% Create the uitable
uicontrol(reg_bot_data_fig,'Style','Text','String','BOTTOM','Units','Normalized','Position',[0.1 0.95 0.3 0.05],'Fontweight','bold','Background','w');
bot_data_table.table_main = uitable('Parent',reg_bot_data_fig,...
    'Data', botDataSummary,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'CellSelectionCallback',@selec_ver_cback,...
    'CellEditCallback',{@insert_comment,main_figure},...
    'ColumnEditable', [false true false],...
    'Units','Normalized','Position',[0 0 0.5 0.95],...
    'RowName',[],'tag','bot');
pos_t = getpixelposition(bot_data_table.table_main);
set(bot_data_table.table_main,'ColumnWidth',...
    num2cell(pos_t(3)*[0.1 0.5 0.4]));
rc_menu = uicontextmenu(ancestor(bot_data_table.table_main,'figure'),'tag','bot');
uimenu(rc_menu,'Label','Load Selected bottom version','Callback',{@import_bot_reg_cback,main_figure});
uimenu(rc_menu,'Label','Remove Selected bottom version','Callback',{@remove_selected_version,main_figure});
bot_data_table.table_main.UIContextMenu =rc_menu;
%set_single_select_mode_table(bot_data_table.table_main) ;

% Create the uitable
uicontrol(reg_bot_data_fig,'Style','Text','String','REGIONS','Units','Normalized','Position',[0.6 0.95 0.3 0.05],'Fontweight','bold','Background','w');
reg_data_table.table_main = uitable('Parent',reg_bot_data_fig,...
    'Data', regDataSummary,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'CellSelectionCallback',@selec_ver_cback,...   
    'CellEditCallback',{@insert_comment,main_figure},...
    'ColumnEditable', [false true false],...
    'Units','Normalized','Position',[0.5 0 0.5 0.95],...
    'RowName',[],'tag','reg');
pos_t = getpixelposition(reg_data_table.table_main);
set(reg_data_table.table_main,'ColumnWidth',...
    num2cell(pos_t(3)*[0.1 0.5 0.4]));

%set_single_select_mode_table(reg_data_table.table_main) ;

rc_menu = uicontextmenu(ancestor(reg_data_table.table_main,'figure'),'tag','reg');
uimenu(rc_menu,'Label','Load Selected region version','Callback',{@import_bot_reg_cback,main_figure});
uimenu(rc_menu,'Label','Remove Selected region version','Callback',{@remove_selected_version,main_figure});
reg_data_table.table_main.UIContextMenu =rc_menu;

setappdata(reg_bot_data_fig,'bot_data_table',bot_data_table);
setappdata(reg_bot_data_fig,'reg_data_table',reg_data_table);
setappdata(reg_bot_data_fig,'bot_ver_select',[]);
setappdata(reg_bot_data_fig,'reg_ver_select',[]);

centerfig(reg_bot_data_fig);
end

function selec_ver_cback(src,event)

reg_bot_data_fig=ancestor(src,'figure');

if size(event.Indices,1)>0
    version=src.Data{event.Indices(end,1),1};
else
    version=[];
end
switch src.Tag
    case 'reg'
        setappdata(reg_bot_data_fig,'reg_ver_select',version);
    case 'bot'
        setappdata(reg_bot_data_fig,'bot_ver_select',version);
end


end

function insert_comment(src,evt,main_figure)
layer=getappdata(main_figure,'Layer');
reg_bot_data_fig=ancestor(src,'figure');

[path_xml,reg_file_str,bot_file_str]=layer.create_files_str();

switch src.Tag
    case 'bot'
       tb=getappdata(reg_bot_data_fig,'bot_data_table');
        str_w='bottom';
        files=bot_file_str;
        str_file='Bot_XML';
    case 'reg'
    
       tb=getappdata(reg_bot_data_fig,'reg_data_table');
        str_w='region';
        files=reg_file_str;
        str_file='Reg_XML';
end
ver=tb.table_main.Data{evt.Indices(1),1};
Comment=tb.table_main.Data{evt.Indices(1),2};
for ip=1:length(path_xml)
    db_file=fullfile(path_xml{ip},'bot_reg.db');
    
    dbconn=sqlite(db_file,'connect');
     
    data_db=dbconn.fetch(sprintf('select Filename,%s,Save_time,Comment,Version from %s WHERE Filename like "%s" AND Version = %f',...
        str_file,str_w,files{ip},ver));
    dbconn.exec(sprintf('delete from %s WHERE Filename is "%s" AND Version = %f',str_w,files{ip},ver));
    dbconn.insert(str_w,{'Filename' str_file 'Save_time' 'Comment' 'Version'},...
    {data_db{1} data_db{2} data_db{3} Comment ver});

    dbconn.close();
end
end

function remove_selected_version(src,~,main_figure)

layer=getappdata(main_figure,'Layer');
reg_bot_data_fig=ancestor(src,'figure');

if isempty(layer)
    return;
end

[path_xml,reg_file_str,bot_file_str]=layer.create_files_str();
switch src.Parent.Tag
    case 'bot'
        ver=getappdata(reg_bot_data_fig,'bot_ver_select');
        str_w='bottom';
        files=bot_file_str;
    case 'reg'
        ver=getappdata(reg_bot_data_fig,'reg_ver_select');
        str_w='region';
        files=reg_file_str;
end
war_str=sprintf('WARNING: This will delete this %s version',str_w);

choice = questdlg(war_str, ...
    'Load XML',...
    'Yes','No', ...
    'No');
% Handle response
switch choice
    case 'No'
        return;
end


for ip=1:length(path_xml)
    db_file=fullfile(path_xml{ip},'bot_reg.db');
    
    dbconn=sqlite(db_file,'connect');
    %test=dbconn.fetch(sprintf('select * from %s WHERE Filename like "%s" AND Version = %f',str_w,file_str{ip},ver));
    dbconn.exec(sprintf('delete from %s WHERE Filename is "%s" AND Version = %f',str_w,files{ip},ver));
    dbconn.close();
end

load_bot_reg_data_fig_from_db(main_figure);
end

function import_bot_reg_cback(src,~,main_figure)

layer=getappdata(main_figure,'Layer');
reg_bot_data_fig=ancestor(src,'figure');

curr_disp=getappdata(main_figure,'Curr_disp');
if isempty(layer)
    return;
end

switch src.Parent.Tag
    case 'bot'
        ver=getappdata(reg_bot_data_fig,'bot_ver_select');
        str_w='Bottom';
    case 'reg'
        ver=getappdata(reg_bot_data_fig,'reg_ver_select');
        str_w='Region';
end
war_str=sprintf('WARNING: This will replace currently defined %s',str_w);

choice = questdlg(war_str, ...
    'Load XML',...
    'Yes','No', ...
    'No');
% Handle response
switch choice
    case 'No'
        return;
end

switch src.Parent.Tag
    case 'bot'
        layer.load_bot_regs('bot_ver',ver,'reg_ver',[]);
        display_bottom(main_figure);
        disp('Bottom imported from database');
    case 'reg'
        layer.load_bot_regs('bot_ver',[],'reg_ver',ver);
        display_regions(main_figure,'both');
        trans_obj=layer.get_trans(curr_disp.Freq);
        curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();
        disp('Regions imported from database');
end

set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
order_stacks_fig(main_figure);

end
