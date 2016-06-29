function create_context_menu_track(main_figure,hfig,line)
context_menu=uicontextmenu;
line.UIContextMenu=context_menu;
uimenu(context_menu,'Label','Load/Display this Line(s)','Callback',{@activate_line_callback,main_figure,hfig});
%uimenu(context_menu,'Label','Edit Survey Data','Callback',{@edit_survey_data_map_callback,main_figure,hfig});%TOFIX!!!!
uimenu(context_menu,'Label','Export Track to CSV','Callback',{@export_track_callback,hfig});
end


function edit_survey_data_map_callback(~,~,main_figure,hfig)
idx_select=getappdata(hfig,'Idx_select');
obj=getappdata(hfig,'Map_input');
files=cell(1,length(idx_select));

obj_id=zeros(1,length(idx_select));

for id=1:length(idx_select)
    files{id}=obj.Filename{idx_select(id)};
    obj_id(id)=idx_select(id);
end
update=0;

for i=1:length(idx_select)
    for il=1:length(files{i})
        if i==1
            survey_data_ori=get_survey_data_from_logbook(files{1}{1});
        else
            survey_data_ori=get_survey_data_from_logbook(files{i-1}{1});
        end
        survey_data_bis=get_survey_data_from_logbook(files{i}{il});
        survey_data_new=survey_data_ori{1};
        survey_data_new.StartTime=survey_data_bis{1}.StartTime;
        survey_data_new.EndTime=survey_data_bis{end}.EndTime;
        [survey_data_new.Voyage,survey_data_new.SurveyName,survey_data_new.Snapshot,survey_data_new.Stratum,survey_data_new.Transect,cancel]=fill_survey_data_dlbox(survey_data_new,'title','Enter New Survey Data');
        if cancel>0
            continue;
        end
        update=1;
        update_echo_logbook_file_manually(files{i}{il},survey_data_new);
    end
    
    obj.SurveyName{obj_id(i)}=survey_data_new.SurveyName;
    obj.Voyage{obj_id(i)}=survey_data_new.Voyage;
    obj.Snapshot(obj_id(i))=survey_data_new.Snapshot;
    obj.Stratum{obj_id(i)}=survey_data_new.Stratum;
    obj.Transect(obj_id(i))=survey_data_new.Transect;
    %update_echo_logbook_file_manually(pathtofile{i},files{i},repmat({survey_data_new},1,length(files{i})));
end

if update>0
    u = findobj(gca,'Tag','name');
    delete(u);
    import_survey_data_callback([],[],main_figure);
end
setappdata(hfig,'Map_input',obj);
end


function activate_line_callback(~,~,main_figure,hfig,idx)
layers=getappdata(main_figure,'Layers');

idx_lines=getappdata(hfig,'Idx_select');
obj=getappdata(hfig,'Map_input');

files={};

for id=1:length(idx_lines)
    files=[files obj.Filename{idx_lines(id)}];
end

if~isempty(layers)
    [idx,found]=layers.find_layer_idx_files_path(files);
else
    found=0;
end

if found==1
    layer=layers(idx(1));
    setappdata(main_figure,'Layer',layer);
    update_display(main_figure,1);
else
    choice = questdlg('We cannot find the transect(s) you are pointing at... Do you want to load it/them?', ...
        'Incomplete',...
        'Yes','No',...
        'Yes');
    % Handle response
    switch choice
        case 'Yes'
            open_file([],[],files,main_figure);
        case 'No'
        otherwise
            return;
    end
    
end
end

function export_track_callback(~,~,hfig)

idx_lines=getappdata(hfig,'Idx_select');
obj=getappdata(hfig,'Map_input');

new_struct.lat=[];
new_struct.lon=[];
new_struct.mat_time=[];

for id=1:length(idx_lines)
    new_struct.lat=[new_struct.lat obj.Lat{idx_lines(id)}];
    new_struct.lon=[new_struct.lon obj.Lon{idx_lines(id)}];
    new_struct.mat_time=[new_struct.mat_time obj.Time{idx_lines(id)}];
end
new_struct.lon(new_struct.lon>180)=new_struct.lon(new_struct.lon>180)-360;

[path,file,~]=fileparts(obj.Filename{idx_lines(1)}{1});

[filename, pathname] = uiputfile('*_track.csv',...
    'Save track as csv file',...
    fullfile(path,[file '_track.csv']));

if isequal(filename,0) || isequal(pathname,0)
    return;
end

struct2csv(new_struct,fullfile(pathname,filename));


end


