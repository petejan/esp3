%% load_logbook_tab_from_db.m
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
% * |main_figure|: Handle to main ESP3 window
% * |reload|: TODO: write description and info on variable
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
function load_logbook_tab_from_db(main_figure,varargin)

p = inputParser;

addRequired(p,'main_figure',@ishandle);
addOptional(p,'reload',0,@isnumeric);
addOptional(p,'new_logbook',0,@isnumeric);
addOptional(p,'filename','',@ischar);
parse(p,main_figure,varargin{:});

new_logbook=p.Results.new_logbook;
reload=p.Results.reload;

layer=getappdata(main_figure,'Layer');
app_path=getappdata(main_figure,'App_path');


if isempty(layer)||new_logbook>0
    if isempty(p.Results.filename)||~exist(p.Results.filename,'file')
        [~,path_f]= uigetfile({fullfile(app_path.data,'echo_logbook.db')}, 'Pick a logbook file','MultiSelect','off');
    if path_f==0
        return;
    end
    [path_f,~,~]=fileparts(path_f);
    else
        [path_f,~,~]=fileparts(p.Results.filename);
    end
    file_add={};
else
    switch layer.Filetype
        case {'CREST','FCV30'}
            return;
        otherwise
            [path_lay,~]=get_path_files(layer);
            path_f=path_lay{1};
    end
    file_add=layer.Filename;
end


db_file=fullfile(path_f,'echo_logbook.db');

if ~(exist(db_file,'file')==2)
    initialize_echo_logbook_dbfile(path_f,0)
end

%surv_data_struct=import_survey_data_db(db_file);

dbconn=sqlite(db_file,'connect');
% user = '';
% password = '';
% driver = 'org.sqlite.JDBC';
% protocol = 'jdbc';
% subprotocol = 'sqlite';
% resource = db_file;
% url = strjoin({protocol, subprotocol, resource}, ':');
% dbconn = database(db_file, user, password, driver, url);


data_survey=dbconn.fetch('select * from survey');
dbconn.close();

dest_fig=getappdata(main_figure,'echo_tab_panel');

tag=sprintf('logbook_%s',path_f);
tab_obj=findobj(dest_fig,'Tag',tag);

if ~isempty(tab_obj)   
    if reload==0
        if strcmp(tab_obj(1).Type,'uitab')
            tab_obj(1).Parent.SelectedTab=tab_obj(1);
        end
        return;
    else
        surv_data_tab=tab_obj(1);
        surv_data_table=getappdata(surv_data_tab,'surv_data_table');
        set(surv_data_table.voy,'String',sprintf('Voyage %s, Survey: %s',data_survey{2},data_survey{1}))
        set(surv_data_tab,'Title',sprintf('Logbook %s',data_survey{2}));
    end
else
    if reload==0
        
        surv_data_tab=uitab(dest_fig,'Title',sprintf('Logbook %s',data_survey{2}),'Tag',tag,'BackgroundColor','White');
        
        surv_data_table.file=uicontrol(surv_data_tab,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.55 0.96 0.075 0.03],'String','File','Value',1,'Callback',{@search_callback,surv_data_tab});
        surv_data_table.snap=uicontrol(surv_data_tab,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.6250 0.96 0.075 0.03],'String','Snap','Value',1,'Callback',{@search_callback,surv_data_tab});
        surv_data_table.strat=uicontrol(surv_data_tab,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.7 0.96 0.075 0.03],'String','Strat','Value',1,'Callback',{@search_callback,surv_data_tab});
        surv_data_table.trans=uicontrol(surv_data_tab,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.775 0.96 0.075 0.03],'String','Trans','Value',1,'Callback',{@search_callback,surv_data_tab});
        surv_data_table.reg=uicontrol(surv_data_tab,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.850 0.96 0.075 0.03],'String','Tag','Value',1,'Callback',{@search_callback,surv_data_tab});
        
        
        surv_data_table.voy=uicontrol(surv_data_tab,'style','text','BackgroundColor','White','units','normalized','position',[0.05 0.96 0.3 0.03],'String',sprintf('Voyage %s, Survey: %s',data_survey{2},data_survey{1}));
        uicontrol(surv_data_tab,'style','text','BackgroundColor','White','units','normalized','position',[0.35 0.96 0.1 0.03],'String','Search :');
        
        surv_data_table.search_box=uicontrol(surv_data_tab,'style','edit','units','normalized','position',[0.45 0.96 0.1 0.03],'HorizontalAlignment','left','Callback',{@search_callback,surv_data_tab});
        
        tab_menu = uicontextmenu(ancestor(surv_data_tab,'figure'));
        surv_data_tab.UIContextMenu=tab_menu;
        uimenu(tab_menu,'Label','Close Logbook','Callback',{@close_logbook_tab,surv_data_tab});
        
        if strcmp(surv_data_tab.Type,'uitab')
            surv_data_tab.Parent.SelectedTab=surv_data_tab;
        end
        
    else
        return;
    end
end

if reload==0
    dbconn=sqlite(db_file,'connect');
    
    data_logbook=dbconn.fetch('select Filename from logbook order by datetime(StartTime)');
    dbconn.close();
    nb_lines=size(data_logbook,1);
    
    if nb_lines==0
        close(surv_data_tab);
        return;
    end
    
    dbconn=sqlite(db_file,'connect');
    createlogbookTable(dbconn);
    %deletegpsTable(dbconn);
    creategpsTable(dbconn);
    
    survDataSummary=update_data_table(dbconn,[],data_logbook,path_f);
    
    dbconn.close();
       

    [types,~]=init_trans_type();
    % Column names and column format
    columnname = {'' 'File','Snap.','Type','Strat.','Trans.','Bot','Reg. Tags','Comment','Start Time','End Time','id'};
    columnformat = {'logical' 'char','numeric',types,'char','numeric','logical','char','char','char','char','numeric'};
    
    
    % Create the uitable
    surv_data_table.table_main = uitable('Parent',surv_data_tab,...
        'Data', survDataSummary,...
        'ColumnName', columnname,...
        'ColumnFormat', columnformat,...
        'CellSelectionCallback',{@cell_select_cback,main_figure},...
        'ColumnEditable', [true false true true true true false false true false false false],...
        'Units','Normalized','Position',[0 0 1 0.95],...
        'KeyPressFcn',{@logbook_keypress_fcn,main_figure},...
        'RowName',[]);
    
    set(surv_data_tab,'SizeChangedFcn',@resize_table);
    
    pos_t = getpixelposition(surv_data_table.table_main);
    set(surv_data_table.table_main,'ColumnWidth',...
        num2cell(pos_t(3)*[1/36,4*1/18, 1/18, 2*1/18,1/18, 1/18,1/36,3*1/36, 2*1/18, 2*1/18,2*1/18, 1/36]));
    set(surv_data_table.table_main,'CellEditCallback',{@edit_surv_data_db,surv_data_tab,main_figure});
    %set(surv_data_table.table_main,'CellSelectionCallback',{@update_surv_data_struct,surv_data_tab});
    
    
    rc_menu = uicontextmenu(ancestor(surv_data_table.table_main,'figure'));
    surv_data_table.table_main.UIContextMenu =rc_menu;
    select_menu=uimenu(rc_menu,'Label','Select');
    process_menu=uimenu(rc_menu,'Label','Process');
    survey_menu=uimenu(rc_menu,'Label','SurveyData');
    uimenu(rc_menu,'Label','XML Survey Script from selected file(s)','Callback',{@generate_xml_callback,surv_data_tab,app_path.scripts});
    uimenu(rc_menu,'Label','Open selected file(s)','Callback',{@open_files_callback,surv_data_tab,main_figure});
    uimenu(select_menu,'Label','Select all','Callback',{@selection_callback,surv_data_tab},'Tag','se');
    uimenu(select_menu,'Label','Deselect all','Callback',{@selection_callback,surv_data_tab},'Tag','de');
    uimenu(select_menu,'Label','Invert Selection','Callback',{@selection_callback,surv_data_tab},'Tag','inv');
    uimenu(process_menu,'Label','Plot/Display bad pings per files','Callback',{@plot_bad_pings_callback,surv_data_tab,main_figure});
    uimenu(survey_menu,'Label','Load Transect Data from CSV','Callback',{@load_logbook_from_csv_callback,main_figure});
    uimenu(survey_menu,'Label','Load Transect Data from xml','Callback',{@load_logbook_from_xml_callback,main_figure});
    uimenu(survey_menu,'Label','Export MetaData to .csv','Callback',{@export_metadata_to_csv_callback,main_figure});
    uimenu(survey_menu,'Label','Export to Html and display','Callback',{@export_metadata_to_html_callback,main_figure});
    
    
    setappdata(surv_data_tab,'path_data',path_f);
    setappdata(surv_data_tab,'surv_data_table',surv_data_table);
    setappdata(surv_data_tab,'data_ori',survDataSummary);
    surv_data_tab.Parent.SelectedTab=surv_data_tab;
else
    reload_logbook_fig(surv_data_tab,file_add);
end
end

function close_logbook_tab(~,~,tab)

delete(tab);

end



function plot_bad_pings_callback(src,~,surv_data_tab,main_figure)

surv_data_table=getappdata(surv_data_tab,'surv_data_table');
data_ori=get(surv_data_table.table_main,'Data');
selected_files=unique(data_ori([data_ori{:,1}],2));
path_f=getappdata(surv_data_tab,'path_data');
files=fullfile(path_f,selected_files);

[nb_bad_pings,nb_pings,files_out,freq_vec]=get_bad_ping_number_from_bottom_xml(files);

[filename, pathname]=uiputfile({'*.txt','Text File'},'Save Bad Ping file',...
    fullfile(path_f,'bad_pings_f'));

if isequal(filename,0) || isequal(pathname,0)
    fid=1;
else
    fid_f=fopen(fullfile(pathname,filename),'w');
    if fid_f~=-1
        fid=[1 fid_f];
    end
end

for ifreq=1:length(freq_vec)
    h_fig=new_echo_figure(main_figure,'ButtonDownFcn',@display_filename_callback,'Tag',sprintf('bp%.0f kHz\n',freq_vec(ifreq)/1e3));
    ax=axes(h_fig);
    plot_temp=plot(ax,nb_bad_pings{ifreq}./nb_pings{ifreq}*100,'--+');
    grid(ax,'on');
    %set(ax,'XTick',1:length(files_out{ifreq}),'XTickLabels',files_out{ifreq},'XTickLabelRotation',45);
    ylabel('%')
    title(sprintf('Bad pings percentage for %.0f kHz',freq_vec(ifreq)/1e3));
    set(plot_temp,'ButtonDownFcn',{@display_filename_callback,files_out{ifreq}});
    
    
    for i=1:length(fid)
        
        fprintf(fid(i),'Bad Pings for frequency %.0f kHz\n',freq_vec(ifreq)/1e3);
        for i_sub=1:length(nb_bad_pings{ifreq})
            fprintf(fid(i),'%s %.2f\n',files_out{ifreq}{i_sub},nb_bad_pings{ifreq}(i_sub)./nb_pings{ifreq}(i_sub)*100);
        end
        fprintf(fid(i),'\n');
        
    end
    
end

for i=1:length(fid)
    if fid(i)~=1
        fclose(fid(i));
    end
end


end

function display_filename_callback(src,evt,file_list)

ax=src.Parent;

text_obj=findall(ax,'Tag','fname');
delete(text_obj);

[~,idx]=nanmin((src.XData-evt.IntersectionPoint(1)).^2+(src.YData-evt.IntersectionPoint(2)).^2);
axes(ax);
text(evt.IntersectionPoint(1),evt.IntersectionPoint(2),file_list{idx},'Tag','fname');


end

function cell_select_cback(src,evt,main_figure)
parent=ancestor(src,'figure');
pathf=getappdata(parent,'path_data');
switch parent.SelectionType
    case 'open'
        if ~isempty(evt.Indices)
            open_file([],[],fullfile(pathf,src.Data{evt.Indices(1,1),2}),main_figure)
        end
end
end


function edit_surv_data_db(src,evt,surv_data_tab,main_figure)%TODO change that so that data are entered into db straight away
if isempty(evt.Indices)
    return;
end

data_ori=getappdata(surv_data_tab,'data_ori');

if isnan(src.Data{evt.Indices(1,1),evt.Indices(1,2)})
    src.Data{evt.Indices(1),evt.Indices(2)}=0;
end

idx_struct=src.Data{evt.Indices(1,1),12};
fields={ '' 'Filename' 'Snapshot' 'Type' 'Stratum' 'Transect' '' '' 'StartTime' 'EndTime' 'Comment' ''};
col_id=evt.Indices(1,2);
row_id=evt.Indices(1,1);
switch col_id
    
    case {1}
        data_ori{idx_struct,evt.Indices(1,2)}=src.Data{evt.Indices(1),evt.Indices(1,2)};
        setappdata(surv_data_tab,'data_ori',data_ori);
        return;
    case{3,4,5,6,9}
         filename=src.Data{row_id,2};
%         snap=src.Data{row_id,3};
%         type=src.Data{row_id,4};
%         strat=src.Data{row_id,5};
%         trans=src.Data{row_id,6};
         st=src.Data{row_id,10};
%         et=src.Data{row_id,11};
%         comm=src.Data{row_id,9};
        new_val=src.Data{row_id,col_id};
        data_ori{idx_struct,col_id}=src.Data{row_id,col_id};
    otherwise
        return;
end

path_f=getappdata(surv_data_tab,'path_data');

db_file=fullfile(path_f,'echo_logbook.db');
if ~(exist(db_file,'file')==2)
    initialize_echo_logbook_dbfile(path_f,0)
end

%surv_data_struct=import_survey_data_db(db_file);

dbconn=sqlite(db_file,'connect');

if dbconn.IsReadOnly
    fprintf('Database file is readonly... Check file permissions\n');
    return;
end
 
%dbconn.fetch(sprintf('delete from logbook where Filename is "%s" and StartTime=%.0f',filename,st));
% dbconn.insert('logbook',{'Filename' 'Snapshot' 'Type' 'Stratum' 'Transect'  'StartTime' 'EndTime' 'Comment'},...
%     {filename snap type strat trans st et comm});
if isnumeric(new_val)
    fmt='%d';
else
    fmt='%s';
end

sql_query=sprintf(['UPDATE logbook SET %s=' fmt ' WHERE Filename IS "%s" and StartTime IS "%s"'],fields{col_id},new_val,filename,st);

dbconn.exec(sql_query);

dbconn.close();

setappdata(surv_data_tab,'data_ori',data_ori);
import_survey_data_callback([],[],main_figure);
display_info_ButtonMotionFcn([],[],main_figure,1)
end


function selection_callback(src,~,surv_data_tab)
surv_data_table=getappdata(surv_data_tab,'surv_data_table');
data_ori=getappdata(surv_data_tab,'data_ori');
data=get(surv_data_table.table_main,'Data');
for i=1:size(data,1)
    switch src.Tag
        case 'se'
            data{i,1}=true;
        case 'de'
            data{i,1}=false;
        case 'inv'
            data{i,1}=~data{i,1};
    end
    data_ori{data{i,12},1}=data{i,1};
end
set(surv_data_table.table_main,'Data',data);
setappdata(surv_data_tab,'data_ori',data_ori);
end


function open_files_callback(src,evt,surv_data_tab,main_figure)
surv_data_table=getappdata(surv_data_tab,'surv_data_table');
data_ori=get(surv_data_table.table_main,'Data');
selected_files=unique(data_ori([data_ori{:,1}],2));
path_f=getappdata(surv_data_tab,'path_data');
files=fullfile(path_f,selected_files);
layers=getappdata(main_figure,'Layers');

if ~isempty(layers)
    [old_files,lay_IDs]=layers.list_files_layers();
    idx_already_open=cellfun(@(x) any(strcmpi(x,old_files)),files);
    
    if any(idx_already_open)
        fprintf('File %s already open in existing layer\n',files{idx_already_open});
        files_open=files(idx_already_open);
        files(idx_already_open)=[];
    end
else
    idx_already_open=[];
end

idx_deleted= find(~cellfun(@(x) exist(x,'file')==2,files));

if ~isempty(idx_deleted)
    
    dbconn=sqlite(fullfile(path_f,'echo_logbook.db'),'connect');
    for i=idx_deleted
        fprintf('Removing %s from logbook... cannot find it anymore.\n',files{i});
        dbconn.exec(sprintf('delete from logbook where Filename is "%s"',selected_files{i}));
    end
    dbconn.close();
    files(idx_deleted)=[];
    reload_logbook_fig(surv_data_tab,{});
end

if isempty(files)
    if any(idx_already_open)
        idx_open=find(strcmpi(files_open{end},old_files));
        [idx_lay,~]=find_layer_idx(layers,lay_IDs{idx_open(end)});
        setappdata(main_figure,'Layer',layers(idx_lay));
        loadEcho(main_figure);
        return;
    end
end
open_file([],[],files,main_figure);
end

function generate_xml_callback(~,~,surv_data_tab,path_scripts)
surv_data_table=getappdata(surv_data_tab,'surv_data_table');
path_f=getappdata(surv_data_tab,'path_data');

surv_data_struct=get_struct_from_db(path_f);
data_ori=get(surv_data_table.table_main,'Data');
path_f=getappdata(surv_data_tab,'path_data');
idx_struct=unique([data_ori{[data_ori{:,1}],12}]);

survey_input_obj=survey_input_cl();

if isempty(idx_struct)
    return;
end

survey_input_obj.Infos.SurveyName=surv_data_struct.SurveyName{idx_struct(1)};
survey_input_obj.Infos.Voyage=surv_data_struct.Voyage{idx_struct(1)};

snapshots=unique(surv_data_struct.Snapshot(idx_struct));
survey_input_obj.Snapshots=cell(1,length(snapshots));
for isnap=1:length(snapshots)
    
    survey_input_obj.Snapshots{isnap}.Folder=path_f;
    survey_input_obj.Snapshots{isnap}.Number=snapshots(isnap);
    survey_input_obj.Snapshots{isnap}.Type={' '};
    survey_input_obj.Snapshots{isnap}.Cal=[];
    idx_snap=idx_struct(surv_data_struct.Snapshot(idx_struct)==snapshots(isnap));
    stratum=unique(surv_data_struct.Stratum(idx_snap));
    survey_input_obj.Snapshots{isnap}.Stratum=cell(1,length(stratum));
    
    for istrat=1:length(stratum)
        idx_strat=idx_snap(strcmp(surv_data_struct.Stratum(idx_snap),stratum{istrat}));
        survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Name=stratum{istrat};
        transects=unique(surv_data_struct.Transect(idx_strat));
        survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects=cell(1,length(transects));
        for itrans=1:length(transects)
            survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.number=transects(itrans);
            survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.Bottom=struct('ver',0);
            survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.Regions{1}=struct('ver',0,'IDs',[]);
            survey_input_obj.Snapshots{isnap}.Stratum{istrat}.Transects{itrans}.Cal=[];
        end
    end
    
end



prompt={'Title',...
    'Areas',...
    'Author',...
    'Main species',...
    'Comments'};

defaultanswer={'','','','',''};

answer=inputdlg(prompt,'XML survey informations',[1;1;1;1;5],defaultanswer);

if isempty(answer)
    return;
end

survey_input_obj.Infos.Title=answer{1};
survey_input_obj.Infos.Areas=answer{2};
survey_input_obj.Infos.Author=answer{3};
survey_input_obj.Infos.Main_species=answer{4};
survey_input_obj.Infos.Comments=answer{5};

if ~isdir(path_scripts)
    path_scripts=path_f;
end

[filename, pathname] = uiputfile('*.xml',...
    'Save survey XML file',...
    fullfile(path_scripts,[survey_input_obj.Infos.Voyage '.xml']));

if isequal(filename,0) || isequal(pathname,0)
    return;
end
survey_input_obj.check_n_complete_input();
survey_input_obj.survey_input_to_survey_xml('xml_filename',fullfile(pathname,filename));

end


