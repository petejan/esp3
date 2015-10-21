function load_mbs_fig(hObject_main,mbsSummary)
hfigs=getappdata(hObject_main,'ExternalFigures');
% Column names and column format
columnname = {'Title','Species','Voyage','Areas','Author','MbsId','Created'};
columnformat = {'char','char','char','char','char','char','char'};

mbs_figure = figure('Position',[100 100 800 600],'Resize','off',...
    'Name','MBSing','NumberTitle','off',...
    'MenuBar','none');%No Matlab Menu)
hfigs_new=[hfigs mbs_figure];
setappdata(hObject_main,'ExternalFigures',hfigs_new);

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
uimenu(rc_menu,'Label','Run on Crest Files','Callback',{@run_mbs_callback,mbs_figure,hObject_main},'tag','crest');
uimenu(rc_menu,'Label','Run on Raw Files','Callback',{@run_mbs_callback,mbs_figure,hObject_main},'tag','raw');
uimenu(rc_menu,'Label','Run with school detection','Callback',{@run_mbs_callback,mbs_figure,hObject_main},'tag','sch');
uimenu(rc_menu,'Label','Edit','Callback',{@edit_mbs_callback,mbs_figure,hObject_main});
selected_mbs={''};

setappdata(mbs_figure,'SelectedMbs',selected_mbs);
setappdata(mbs_figure,'MBS_table',mbs_table);
setappdata(mbs_figure,'DataOri',mbsSummary);

end


function run_mbs_callback(src,~,hObject,hObject_main)

selected_mbs=getappdata(hObject,'SelectedMbs');
app_path=getappdata(hObject_main,'App_path');
curr_disp=getappdata(hObject_main,'Curr_disp');
layers_old=getappdata(hObject_main,'Layers');
mbs_vec=getappdata(hObject_main,'MBS');

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
            layers=load_files_regions(mbs,'PathToMemmap',app_path.data,'CVSroot',app_path.cvs_root,'idx_trans',idx_trans);
        case 'raw'
            layers=load_files_regions(mbs,'PathToMemmap',app_path.data,'CVSroot',app_path.cvs_root,'idx_trans',idx_trans,'type','raw');
        case 'sch'
            layers=load_files_regions(mbs,'PathToMemmap',app_path.data,'CVSroot',app_path.cvs_root,'idx_trans',idx_trans,'mode','sch');
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
    if ~isempty(mbs_vec)
        idx=find_mbs(mbs_vec,mbs.Header.MbsId);
        if ~isempty(idx)
            mbs_vec(idx)=[];
        end
    end
    mbs_vec=[mbs_vec mbs];
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

idx_freq=find_freq_idx(layer,curr_disp.Freq);
curr_disp.Freq=layer.Frequencies(idx_freq);
curr_disp.setField('sv');

setappdata(hObject_main,'MBS',mbs_vec);
setappdata(hObject_main,'Layer',layer);
setappdata(hObject_main,'Layers',layers);
setappdata(hObject_main,'Curr_disp',curr_disp);
update_display(hObject_main,1);
load_map_fig(hObject_main,mbs_vec);

end

function edit_mbs_callback(~,~,hObject,hObject_main)
app_path=getappdata(hObject_main,'App_path');
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

