function load_survey_data_fig_from_db(main_figure,reload)
layer=getappdata(main_figure,'Layer');
app_path=getappdata(main_figure,'App_path');


if isempty(layer)
    path_f = uigetdir(app_path.data,'Choose Data Folder');
    if path_f==0
        return;
    end
else
    switch layer.Filetype
        case 'CREST'
            return;
        otherwise
            [path_lay,~]=get_path_files(layer);
            path_f=path_lay{1};
    end
    
end




db_file=fullfile(path_f,'echo_logbook.db');

if ~(exist(db_file,'file')==2)
    initialize_echo_logbook_dbfile(path_f,0)
end

%surv_data_struct=import_survey_data_db(db_file);

dbconn=sqlite(db_file,'connect');

data_survey=dbconn.fetch('select * from survey');
dbconn.close();

hfigs=getappdata(main_figure,'ExternalFigures');
hfigs(~isvalid(hfigs))=[];
idx_tag=find(strcmpi({hfigs(:).Tag},sprintf('logbook_%s',data_survey{2})));

if ~isempty(idx_tag)
    if reload==0
        figure(hfigs(idx_tag(1)))
        return;
    else
        surv_data_fig=hfigs(idx_tag(1));
        surv_data_table=getappdata(surv_data_fig,'surv_data_table');
    end
else
    if reload==0
        size_max = get(0, 'MonitorPositions');
        
        surv_data_fig = figure(...
            'Units','pixels',...
            'Position',[size_max(1,1)+size_max(1,3)/4 size_max(1,2)+1/5*size_max(1,4) size_max(1,3)/2 3*size_max(1,4)/5],...
            'Resize','on',...
            'MenuBar','none',...
            'Name','SurveyData','Tag',sprintf('logbook_%s',data_survey{2}));
        
        surv_data_table.file=uicontrol(surv_data_fig,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.55 0.96 0.075 0.03],'String','File','Value',1,'Callback',{@search_callback,surv_data_fig});
        surv_data_table.snap=uicontrol(surv_data_fig,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.6250 0.96 0.075 0.03],'String','Snap','Value',1,'Callback',{@search_callback,surv_data_fig});
        surv_data_table.strat=uicontrol(surv_data_fig,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.7 0.96 0.075 0.03],'String','Strat','Value',1,'Callback',{@search_callback,surv_data_fig});
        surv_data_table.trans=uicontrol(surv_data_fig,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.775 0.96 0.075 0.03],'String','Trans','Value',1,'Callback',{@search_callback,surv_data_fig});
        surv_data_table.reg=uicontrol(surv_data_fig,'style','checkbox','BackgroundColor','White','units','normalized','position',[0.850 0.96 0.075 0.03],'String','Tag','Value',1,'Callback',{@search_callback,surv_data_fig});
        
        
        uicontrol(surv_data_fig,'style','text','BackgroundColor','White','units','normalized','position',[0.05 0.96 0.3 0.03],'String',sprintf('Voyage %s, Survey: %s',data_survey{2},data_survey{1}));
        uicontrol(surv_data_fig,'style','text','BackgroundColor','White','units','normalized','position',[0.35 0.96 0.1 0.03],'String','Search :');
        
        surv_data_table.search_box=uicontrol(surv_data_fig,'style','edit','units','normalized','position',[0.45 0.96 0.1 0.03],'HorizontalAlignment','left','Callback',{@search_callback,surv_data_fig});
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
        close(surv_data_fig);
        return;
    end
    
    dbconn=sqlite(db_file,'connect');
    survDataSummary=update_data_table(dbconn,[],data_logbook,path_f);

    dbconn.close();
    
  
    % Column names and column format
    columnname = {'' 'File','Snap.','Strat.','Trans.','Bot','Reg','Comment' 'Start Time','End Time'  'id'};
    columnformat = {'logical' 'char','numeric','char','numeric','logical','char','char','char','char','numeric'};
    
    
    % Create the uitable
    surv_data_table.table_main = uitable('Parent',surv_data_fig,...
        'Data', survDataSummary,...
        'ColumnName', columnname,...
        'ColumnFormat', columnformat,...
        'ColumnEditable', [true false true true true false false true false false false],...
        'Units','Normalized','Position',[0 0 1 0.95],...
        'RowName',[]);
    
    set(surv_data_fig,'SizeChangedFcn',@resize_table);
    
    pos_t = getpixelposition(surv_data_table.table_main);
    set(surv_data_table.table_main,'ColumnWidth',...
        num2cell(pos_t(3)*[1/36,4*1/18, 1/18, 1/18, 1/18,1/36,3*1/36, 4*1/18, 2*1/18,2*1/18, 1/36]));
    set(surv_data_table.table_main,'CellEditCallback',{@edit_surv_data_db,surv_data_fig,main_figure});
    %set(surv_data_table.table_main,'CellSelectionCallback',{@update_surv_data_struct,surv_data_fig});
    
    
    rc_menu = uicontextmenu(surv_data_fig);
    surv_data_table.table_main.UIContextMenu =rc_menu;
    select_menu=uimenu(rc_menu,'Label','Select');
    process_menu=uimenu(rc_menu,'Label','Process');
    survey_menu=uimenu(rc_menu,'Label','SurveyData');
    uimenu(rc_menu,'Label','XML Survey Script from selected file(s)','Callback',{@generate_xml_callback,surv_data_fig,app_path.scripts});
    uimenu(rc_menu,'Label','Open selected file(s)','Callback',{@open_files_callback,surv_data_fig,main_figure});
    uimenu(select_menu,'Label','Select all','Callback',{@selection_callback,surv_data_fig},'Tag','se');
    uimenu(select_menu,'Label','Deselect all','Callback',{@selection_callback,surv_data_fig},'Tag','de');
    uimenu(select_menu,'Label','Invert Selection','Callback',{@selection_callback,surv_data_fig},'Tag','inv');
    uimenu(process_menu,'Label','Plot/Display bad pings per files','Callback',{@plot_bad_pings_callback,surv_data_fig,main_figure});
    uimenu(survey_menu,'Label','Load Transect Data from CSV','Callback',{@load_logbook_from_csv_callback,main_figure});
    uimenu(survey_menu,'Label','Load Transect Data from xml','Callback',{@load_logbook_from_xml_callback,main_figure});
    uimenu(survey_menu,'Label','Export MetaData to .csv','Callback',{@export_metadata_to_csv_callback,main_figure});
    uimenu(survey_menu,'Label','Export to Html and display','Callback',{@export_metadata_to_html_callback,main_figure});
    uimenu(survey_menu,'Label','Edit Voyage Info','Callback',{@edit_trip_info_callback,main_figure});
    
    
    setappdata(surv_data_fig,'path_data',path_f);
    setappdata(surv_data_fig,'surv_data_table',surv_data_table);
    setappdata(surv_data_fig,'data_ori',survDataSummary);
    
    new_echo_figure(main_figure,'fig_handle',surv_data_fig);
    
else
    path_f=getappdata(surv_data_fig,'path_data');
    data_ori=getappdata(surv_data_fig,'data_ori');
    dbconn=sqlite(db_file,'connect');
    data_ori_new=update_data_table(dbconn,data_ori,layer.Filename,path_f);
    setappdata(surv_data_fig,'data_ori',data_ori_new);
    set(surv_data_table.table_main,'Data',data_ori_new);
    dbconn.close();
    search_callback([],[],surv_data_fig);
end
end

function data_ori_new=update_data_table(dbconn,data_ori,filename_cell,path_f)
data_ori_new=data_ori;
for i=1:length(filename_cell)
    [~,file_c,ext_c]=fileparts(filename_cell{i});
    data_logbook_to_up=dbconn.fetch(sprintf('select Filename,Snapshot,Stratum,Transect,Comment,StartTime,EndTime from logbook where Filename = ''%s''',[file_c ext_c]));
    
    if~isempty(data_ori_new)
        idx_mod=find(strcmpi(data_ori_new(:,2),[file_c ext_c]));
    else
        idx_mod=[];
    end
    if~isempty(idx_mod)
        data_ori_new(idx_mod,:)=[];
    end
    
    nb_lines_new=size(data_logbook_to_up,1);
    new_entry=cell(nb_lines_new,11);
    new_entry(:,1)=cell(nb_lines_new,1);
    new_entry(:,2)=data_logbook_to_up(:,1);
    new_entry(:,3)=data_logbook_to_up(:,2);
    new_entry(:,4)=data_logbook_to_up(:,3);
    new_entry(:,5)=data_logbook_to_up(:,4);
    new_entry(:,8)=data_logbook_to_up(:,5);
    new_entry(:,9)=data_logbook_to_up(:,6);
    new_entry(:,10)=data_logbook_to_up(:,7);
    new_entry(:,11)=num2cell(1:nb_lines_new);
    
    for il=1:nb_lines_new
        [path_xml,bot_file_str,reg_file_str]=create_bot_reg_xml_fname(fullfile(path_f,data_logbook_to_up{il,1}));
        new_entry{il,6}=exist(fullfile(path_xml,bot_file_str),'file')==2;
        if exist(fullfile(path_xml,reg_file_str),'file')==2
            tags = list_tags_only_regions_xml(fullfile(path_xml,reg_file_str));
            if ~isempty(tags)
                str_reg=cell2mat(cellfun(@(x) [ x ' ' ], unique(tags), 'UniformOutput', false));
                new_entry{il,7}=str_reg;
            else
               new_entry{il,7}=''; 
            end
        else
            new_entry{il,7}='';
        end
        new_entry{il,1}=false;
    end
    
    data_ori_new=[data_ori_new;new_entry];
    
end
[~,idx_sort]=sort(data_ori_new(:,9));
data_ori_new=data_ori_new(idx_sort,:);
data_ori_new(:,11)=num2cell(1:size(data_ori_new,1));

end

function resize_table(src,~)
table=findobj(src,'Type','uitable');

if~isempty(table)
    column_width=table.ColumnWidth;
    pos_f=getpixelposition(src);
    width_t_old=nansum([column_width{:}]);
    width_t_new=pos_f(3);
    new_width=cellfun(@(x) x/width_t_old*width_t_new,column_width,'un',0);
    set(table,'ColumnWidth',new_width);
end

end

function plot_bad_pings_callback(src,~,surv_data_fig,main_figure)

surv_data_table=getappdata(surv_data_fig,'surv_data_table');
data_ori=get(surv_data_table.table_main,'Data');
selected_files=unique(data_ori([data_ori{:,1}],2));
path_f=getappdata(surv_data_fig,'path_data');
files=fullfile(path_f,selected_files);

[nb_bad_pings,nb_pings,files_out,freq_vec]=get_bad_ping_number_from_bottom_xml(files);

[filename, pathname]=uiputfile({'*.txt','Text File'},'Save Bad Ping file',...
    fullfile(path_f,'bad_pings_f'));

if isequal(filename,0) || isequal(pathname,0)
    fid=1;
else
    fid_f=fopen(fullfile(pathname,filename),'w+');
    if fid_f~=-1
        fid=[1 fid_f];
    end
end

for ifreq=1:length(freq_vec)
    new_echo_figure(main_figure,'ButtonDownFcn',@display_filename_callback,'Tag',sprintf('bp%.0fkHz\n',freq_vec(ifreq)/1e3));
    plot_temp=plot(nb_bad_pings{ifreq}./nb_pings{ifreq}*100,'--+');
    grid on;
    %set(ax,'XTick',1:length(files_out{ifreq}),'XTickLabels',files_out{ifreq},'XTickLabelRotation',45);
    ylabel('%')
    title(sprintf('Bad pings percentage for %.0fkHz',freq_vec(ifreq)/1e3));
    set(plot_temp,'ButtonDownFcn',{@display_filename_callback,files_out{ifreq}});
    
    
    for i=1:length(fid)
        
        fprintf(fid(i),'Bad Pings for frequency %.0fkHz\n',freq_vec(ifreq)/1e3);
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


function edit_surv_data_db(src,evt,surv_data_fig,main_figure)%TODO change that so that data are entered into db straight away
if isempty(evt.Indices)
    return;
end

data_ori=getappdata(surv_data_fig,'data_ori');

if isnan(src.Data{evt.Indices(1,1),evt.Indices(1,2)})
    src.Data{evt.Indices(1),evt.Indices(2)}=0;
end

idx_struct=src.Data{evt.Indices(1,1),11};

switch evt.Indices(1,2)
    case {1}
        data_ori{idx_struct,evt.Indices(1,2)}=src.Data{evt.Indices(1),evt.Indices(1,2)};
        setappdata(surv_data_fig,'data_ori',data_ori);
        return;
    case{3,4,5,8}
        filename=src.Data{evt.Indices(1,1),2};
        snap=src.Data{evt.Indices(1,1),3};
        strat=src.Data{evt.Indices(1,1),4};
        trans=src.Data{evt.Indices(1,1),5};
        st=src.Data{evt.Indices(1,1),9};
        et=src.Data{evt.Indices(1,1),10};
        comm=src.Data{evt.Indices(1,1),8};
        data_ori{idx_struct,evt.Indices(1,2)}=src.Data{evt.Indices(1,1),evt.Indices(1,2)};
    otherwise
        return;
end

path_f=getappdata(surv_data_fig,'path_data');

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

%dbconn.fetch(sprintf('delete from logbook where Filename like "%s" and StartTime=%.0f',filename,st));
dbconn.insert('logbook',{'Filename' 'Snapshot' 'Stratum' 'Transect'  'StartTime' 'EndTime' 'Comment'},...
    {filename snap strat trans st et comm});

dbconn.close();

setappdata(surv_data_fig,'data_ori',data_ori);
import_survey_data_callback([],[],main_figure);
display_info_ButtonMotionFcn([],[],main_figure,1)
end


function selection_callback(src,~,surv_data_fig)
surv_data_table=getappdata(surv_data_fig,'surv_data_table');
data_ori=getappdata(surv_data_fig,'data_ori');
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
    data_ori{data{i,11},1}=data{i,1};
end
set(surv_data_table.table_main,'Data',data);
setappdata(surv_data_fig,'data_ori',data_ori);
end


function open_files_callback(src,evt,surv_data_fig,main_figure)
surv_data_table=getappdata(surv_data_fig,'surv_data_table');
data_ori=get(surv_data_table.table_main,'Data');
selected_files=unique(data_ori([data_ori{:,1}],2));
path_f=getappdata(surv_data_fig,'path_data');
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

if isempty(files)
    if~isempty(idx_already_open)
        idx_open=find(strcmpi(files_open{end},old_files));
        [idx_lay,~]=find_layer_idx(layers,lay_IDs(idx_open(end)));
        setappdata(main_figure,'Layer',layers(idx_lay));
        loadEcho(main_figure);
        return;
    end
end
open_file([],[],files,main_figure);
end

function generate_xml_callback(~,~,surv_data_fig,path_scripts)
surv_data_table=getappdata(surv_data_fig,'surv_data_table');
path_f=getappdata(surv_data_fig,'path_data');

surv_data_struct=get_struct_from_db(path_f);
data_ori=get(surv_data_table.table_main,'Data');
path_f=getappdata(surv_data_fig,'path_data');
idx_struct=unique([data_ori{[data_ori{:,1}],11}]);

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

function search_callback(~,~,surv_fig)
surv_data_table=getappdata(surv_fig,'surv_data_table');
data_ori=getappdata(surv_fig,'data_ori');
text_search=regexprep(get(surv_data_table.search_box,'string'),'[^\w'']','');

file=get(surv_data_table.file,'value');
snap=get(surv_data_table.snap,'value');
strat=get(surv_data_table.strat,'value');
trans=get(surv_data_table.trans,'value');
reg=get(surv_data_table.reg,'value');

if isempty(text_search)||(~file&&~snap&&~trans&&~strat&&~reg)
    data=data_ori;
else
    
    if snap>0
        idx_snap=cell2mat(data_ori(:,3))==snap;
    else
        idx_snap=zeros(size(data_ori,1),1);
    end
    
    
    if trans>0
        idx_trans=cell2mat(data_ori(:,5))==trans;
    else
        idx_trans=zeros(size(data_ori,1),1);
    end
    
    if strat>0
        idx_strat=strcmpi(data_ori(:,4),text_search);
    else
        idx_strat=zeros(size(data_ori,1),1);
    end
    
    if file>0
        files=regexprep(data_ori(:,2),'[^\w'']','');
        out_files=regexpi(files,text_search);
        idx_files=cellfun(@(x) ~isempty(x),out_files);
    else
        idx_files=zeros(size(data_ori,1),1);
    end
    
    if reg>0
        regs=regexprep(data_ori(:,7),'[^\w'']','');
        out_regs=regexpi(regs,text_search);
        idx_regs=cellfun(@(x) ~isempty(x),out_regs);
    else
        idx_regs=zeros(size(data_ori,1),1);
    end
    
    data=data_ori(idx_snap|idx_strat|idx_files|idx_trans|idx_regs,:);
    
end

set(surv_data_table.table_main,'Data',data);

end

