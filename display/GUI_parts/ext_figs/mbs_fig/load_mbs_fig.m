function load_mbs_fig(main_figure,mbsSummary)
hfigs=getappdata(main_figure,'ExternalFigures');
% Column names and column format
columnname = {'Title','Species','Voyage','Areas','Author','MbsId','Created'};
columnformat = {'char','char','char','char','char','char','char'};

mbs_figure = figure('Position',[100 100 800 600],'Resize','off',...
    'Name','MBSing','NumberTitle','off',...
    'MenuBar','none');%No Matlab Menu)
hfigs_new=[hfigs mbs_figure];
setappdata(main_figure,'ExternalFigures',hfigs_new);

uicontrol(mbs_figure,'style','text','units','normalized','position',[0.05 0.96 0.15 0.03],'String','Search: ');
mbs_table.search_box=uicontrol(mbs_figure,'style','edit','units','normalized','position',[0.2 0.96 0.3 0.03],'HorizontalAlignment','left','Callback',{@search_callback,mbs_figure});

uicontrol(mbs_figure,'style','text','units','normalized','position',[0.55 0.96 0.1 0.03],'String','Filter (or): ');
mbs_table.title_box=uicontrol(mbs_figure,'style','checkbox','units','normalized','position',[0.65 0.96 0.1 0.03],'String','Titles','Value',1,'Callback',{@search_callback,mbs_figure});
mbs_table.species_box=uicontrol(mbs_figure,'style','checkbox','units','normalized','position',[0.75 0.96 0.1 0.03],'String','Species','Value',1,'Callback',{@search_callback,mbs_figure});
mbs_table.voyage_box=uicontrol(mbs_figure,'style','checkbox','units','normalized','position',[0.85 0.96 0.1 0.03],'String','Voyage','Value',1,'Callback',{@search_callback,mbs_figure});


% Create the uitable
mbs_table.table_main = uitable('Parent',mbs_figure,...
    'Data', mbsSummary,...
    'ColumnName', columnname,...
    'ColumnFormat', columnformat,...
    'ColumnEditable', [false false false false false false],...
    'Units','Normalized','Position',[0 0 1 0.95],...
    'RowName',[]);

set(mbs_table.table_main,'Units','pixels');
pos_t=get(mbs_table.table_main,'Position');
set(mbs_table.table_main,'ColumnWidth',{2*pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, pos_t(3)/10, 2*pos_t(3)/10, 2*pos_t(3)/10});
set(mbs_table.table_main,'CellSelectionCallback',{@store_selected_mbs_callback,mbs_figure})

rc_menu = uicontextmenu;
mbs_table.table_main.UIContextMenu =rc_menu;
% uimenu(rc_menu,'Label','Run on Crest Files','Callback',{@run_mbs_callback,mbs_figure,main_figure},'tag','crest');
% uimenu(rc_menu,'Label','Run on Raw Files','Callback',{@run_mbs_callback,mbs_figure,main_figure},'tag','raw');
% uimenu(rc_menu,'Label','Run with school detection','Callback',{@run_mbs_callback,mbs_figure,main_figure},'tag','sch');
uimenu(rc_menu,'Label','Run on Crest Files','Callback',{@run_mbs_callback_v2,mbs_figure,main_figure},'tag','crest');
uimenu(rc_menu,'Label','Run on Raw Files','Callback',{@run_mbs_callback_v2,mbs_figure,main_figure},'tag','raw');
uimenu(rc_menu,'Label','Edit','Callback',{@edit_mbs_callback,mbs_figure,main_figure});
selected_mbs={''};

setappdata(mbs_figure,'SelectedMbs',selected_mbs);
setappdata(mbs_figure,'MBS_table',mbs_table);
setappdata(mbs_figure,'DataOri',mbsSummary);

end


function run_mbs_callback(src,~,hObject,main_figure)

selected_mbs=getappdata(hObject,'SelectedMbs');
app_path=getappdata(main_figure,'App_path');
curr_disp=getappdata(main_figure,'Curr_disp');
layers_old=getappdata(main_figure,'Layers');
mbs_vec=[];

for i=1:length(selected_mbs)
    %try
    curr_mbs=selected_mbs{i};
    if~strcmp(curr_mbs,'')
        [fileNames,outDir]=get_mbs_from_esp2(app_path.cvs_root,'MbsId',curr_mbs,'Rev',[]);
    end
    
    mbs=mbs_cl();
    mbs.readMbsScript(app_path.data_root,fileNames{1});
    rmdir(outDir,'s');
    idx_trans=[];
    
    switch src.Tag
        case 'crest'
            layers=load_files_regions_from_mbs(mbs,'PathToMemmap',app_path.data_temp,'CVSroot',app_path.cvs_root,'idx_trans',idx_trans);
        case 'raw'
            layers=load_files_regions_from_mbs(mbs,'PathToMemmap',app_path.data_temp,'CVSroot',app_path.cvs_root,'idx_trans',idx_trans,'type','raw');
        case 'sch'
            layers=load_files_regions_from_mbs(mbs,'PathToMemmap',app_path.data_temp,'CVSroot',app_path.cvs_root,'idx_trans',idx_trans,'mode','sch');
    end
    
    mbs.generate_output(layers,'idx_trans',idx_trans);
    output_filename=sprintf('mbs_output_%s_%s_%s.txt',regexprep(mbs.Header.voyage,'[^\w'']',''),regexprep(mbs.Header.title,'[^\w'']',''),src.Tag);
    mbs.OutputFile=fullfile(mbs.Input.crestDir{1},output_filename);
    
    mbs.print_output;
    fprintf(1,'Results save to %s \n',mbs.OutputFile);
    
    
    %     catch ME
    %         disp(ME.identifier);
    %         continue;
    %     end
    
    layers_old=[layers_old layers];
   
end

layers=layers_old;
if ~isempty(layers)
    [~,found]=find_layer_idx(layers,0);
else
    found=0;
end
if  found==1
    layers=layers.delete_layers(0);
end

layer=layers(end);

setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Curr_disp',curr_disp);
update_display(main_figure,1);


end


function run_mbs_callback_v2(src,~,hObject,main_figure)

selected_mbs=getappdata(hObject,'SelectedMbs');
app_path=getappdata(main_figure,'App_path');

layers=getappdata(main_figure,'Layers');

[layers,~]=process_surveys(selected_mbs,'PathToMemmap',app_path.data_temp,'layers',layers,'origin','mbs','cvs_root',app_path.cvs_root,'data_root',app_path.data_root,'tag',src.Tag);

if ~isempty(layers)
    [~,found]=find_layer_idx(layers,0);
else
    found=0;
end
if  found==1
    layers=layers.delete_layers(0);
end

if ~isempty(layers)
    layer=layers(end);
    setappdata(main_figure,'Layer',layer);
    setappdata(main_figure,'Layers',layers); 
    update_display(main_figure,1);
end

end

function edit_mbs_callback(~,~,hObject,main_figure)
app_path=getappdata(main_figure,'App_path');
selected_mbs=getappdata(hObject,'SelectedMbs');
if~strcmp(selected_mbs,'')
    [fileNames,outDir]=get_mbs_from_esp2(app_path.cvs_root,'MbsId',selected_mbs{end},'Rev',[]);
    edit(fileNames{1});
    rmdir(outDir,'s');
end
end

function store_selected_mbs_callback(src,event,hObject)
if size(event.Indices,1)>0
    selected_mbs=src.Data(event.Indices(:,1),6);
else
    selected_mbs={''};
end
setappdata(hObject,'SelectedMbs',selected_mbs);
end

function search_callback(~,~,mb_fig)
table=getappdata(mb_fig,'MBS_table');
data_ori=getappdata(mb_fig,'DataOri');
text_search=regexprep(get(table.search_box,'string'),'[^\w'']','');
title_search=get(table.title_box,'value');
voyage_search=get(table.voyage_box,'value');
species_search=get(table.species_box,'value');

if isempty(text_search)||(voyage_search==0&&title_search==0&&species_search==0)
    data=data_ori;
else
    
    if voyage_search>0
        voyages=regexprep(data_ori(:,3),'[^\w'']','');
        out_voyage=regexpi(voyages,text_search);
        idx_voyage=cellfun(@(x) ~isempty(x),out_voyage);
    else
        idx_voyage=zeros(size(data_ori,1),1);
    end
    
    if species_search>0
        species=regexprep(data_ori(:,2),'[^\w'']','');
        out_species=regexpi(species,text_search);
        idx_species=cellfun(@(x) ~isempty(x),out_species);
    else
        idx_species=zeros(size(data_ori,1),1);
    end
    
    if title_search>0
        titles=regexprep(data_ori(:,1),'[^\w'']','');
        out_title=regexpi(titles,text_search);
        idx_title=cellfun(@(x) ~isempty(x),out_title);
    else
        idx_title=zeros(size(data_ori,1),1);
    end
    
    
    
    data=data_ori(idx_voyage|idx_title|idx_species,:);
end

set(table.table_main,'Data',data);
setappdata(mb_fig,'MBS_table',table);
end

