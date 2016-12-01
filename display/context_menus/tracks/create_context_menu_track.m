function create_context_menu_track(main_figure,hfig,line)
context_menu=uicontextmenu(hfig);
line.UIContextMenu=context_menu;
uimenu(context_menu,'Label','Load/Display this Line(s)','Callback',{@activate_line_callback,main_figure,hfig});
uimenu(context_menu,'Label','Export Track to CSV','Callback',{@export_track_callback,hfig});
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
    [idx,found]=layers.find_layer_idx_files(files);
else
    found=0;
end

if found==1
    layer=layers(idx(1));
    setappdata(main_figure,'Layer',layer);
    loadEcho(main_figure);
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


T = struct2table(new_struct);

writetable(T,fullfile(pathname,filename));

end


