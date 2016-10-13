
function load_path_fig(~,~,main_fig)
path_fig = new_echo_figure('Position','Units','Pixels',[200 200 600 300],'Resize','off',...
    'Name','Path Options','MenuBar','none','WindowStyle','modal');

app_path=getappdata(main_fig,'App_path');

app_path_main=whereisEcho();
icon=get_icons_cdata(fullfile(app_path_main,'icons'));


%%%%%Data Folder Start%%%%
uicontrol(path_fig,'Style','text',...
    'Units','normalized',...
    'Position',[0.1 0.85 0.2 0.1],...
    'string','Default Data Folder',...
    'HorizontalAlignment','left');

controls.main_path_edit = uicontrol(path_fig,'Style','edit',...
    'Units','normalized',...
    'Position',[0.3 0.85 0.5 0.1],...
    'BackgroundColor','w',...
    'string',app_path.data,...
    'HorizontalAlignment','left',...
    'Tag','main_path','Callback',{@check_path_callback,path_fig,},'tag','data');

controls.main_path_button=uicontrol(path_fig,'Style','pushbutton','units','normalized',...
    'pos',[0.8 0.85 0.05 0.1],...
    'Cdata',icon.folder,...
    'BackgroundColor','white','callback',{@select_folder_callback,path_fig,controls.main_path_edit});

%%%%%Data%%%%
uicontrol(path_fig,'Style','text',...
    'Units','normalized',...
    'Position',[0.1 0.7 0.2 0.1],...
    'string','Data Root',...
    'HorizontalAlignment','left');

controls.data_path_edit = uicontrol(path_fig,'Style','edit',...
    'Units','normalized',...
    'Position',[0.3 0.7 0.5 0.1],...
    'BackgroundColor','w',...
    'string',app_path.data_root,...
    'HorizontalAlignment','left',...
    'Tag','main_path','Callback',{@check_path_callback,path_fig,},'tag','data_root');

controls.data_path_button=uicontrol(path_fig,'Style','pushbutton','units','normalized',...
    'pos',[0.8 0.7 0.05 0.1],...
    'Cdata',icon.folder,...
    'BackgroundColor','white','callback',{@select_folder_callback,path_fig,controls.data_path_edit});

%%%%%CVS%%%%
uicontrol(path_fig,'Style','text',...
    'Units','normalized',...
    'Position',[0.1 0.55 0.2 0.1],...
    'string','CVS',...
    'HorizontalAlignment','left');

controls.cvs_path_edit = uicontrol(path_fig,'Style','edit',...
    'Units','normalized',...
    'Position',[0.3 0.55 0.5 0.1],...
    'BackgroundColor','w',...
    'string',app_path.cvs_root,...
    'HorizontalAlignment','left',...
    'Tag','main_path','Callback',{@check_path_callback,path_fig,},'tag','cvs_root');

%%%%%Scripts%%%%
uicontrol(path_fig,'Style','text',...
    'Units','normalized',...
    'Position',[0.1 0.4 0.2 0.1],...
    'string','Scripts',...
    'HorizontalAlignment','left');

controls.script_path_edit = uicontrol(path_fig,'Style','edit',...
    'Units','normalized',...
    'Position',[0.3 0.4 0.5 0.1],...
    'BackgroundColor','w',...
    'string',app_path.scripts,...
    'HorizontalAlignment','left',...
    'Tag','main_path','Callback',{@check_path_callback,path_fig,},'tag','scripts');

controls.temp_path_button=uicontrol(path_fig,'Style','pushbutton','units','normalized',...
    'pos',[0.8 0.4 0.05 0.1],...
    'Cdata',icon.folder,...
    'BackgroundColor','white','callback',{@select_folder_callback,path_fig,controls.script_path_edit});


%%%%%Temp%%%%
uicontrol(path_fig,'Style','text',...
    'Units','normalized',...
    'Position',[0.1 0.25 0.2 0.1],...
    'string','Temp',...
    'HorizontalAlignment','left');

controls.temp_path_edit = uicontrol(path_fig,'Style','edit',...
    'Units','normalized',...
    'Position',[0.3 0.25 0.5 0.1],...
    'BackgroundColor','w',...
    'string',app_path.data_temp,...
    'HorizontalAlignment','left',...
    'Tag','main_path','Callback',{@check_path_callback,path_fig,},'tag','data');

controls.temp_path_button=uicontrol(path_fig,'Style','pushbutton','units','normalized',...
    'pos',[0.8 0.25 0.05 0.1],...
    'Cdata',icon.folder,...
    'BackgroundColor','white','callback',{@select_folder_callback,path_fig,controls.temp_path_edit});


%%%Save
uicontrol(path_fig,'Style','pushbutton','units','normalized',...
    'string','Save','pos',[0.7 0.05 0.2 0.1],...
    'TooltipString', 'Save Path',...
    'HorizontalAlignment','left','BackgroundColor','white','callback',{@validate_path,path_fig,main_fig});


setappdata(path_fig,'Controls',controls);
setappdata(path_fig,'AppPath_temp',app_path);
movegui(path_fig,'center');


end

function check_path_callback(src,~,path_fig)
app_path=getappdata(path_fig,'AppPath_temp');
new_path=get(src,'string');
if isdir(new_path)||strcmp(src.Tag,'cvs_root')
    app_path.(src.Tag)=new_path;
else
    set(src,'string',app_path.(src.Tag));
end
setappdata(path_fig,'AppPath_temp',app_path);
end

function select_folder_callback(~,~,path_fig,edit_box)
path_ori=get(edit_box,'string');
new_path = uigetdir(path_ori);
if new_path~=0
    set(edit_box,'string',new_path);
end
check_path_callback(edit_box,[],path_fig);
end

function validate_path(~,~,path_fig,main_fig)
layer=getappdata(main_fig,'Layer');
curr_disp=getappdata(main_fig,'Curr_disp');
if ~isempty(layer)
    idx_freq=find_freq_idx(layer,curr_disp.Freq);
    algos=layer.Transceivers(idx_freq).Algo;
else
    algos=[];
end
app_path=getappdata(path_fig,'AppPath_temp');
setappdata(main_fig,'App_path',app_path);
main_path=whereisEcho();

[~,~,algos]=load_config_from_xml(fullfile(main_path,'config','config_echo.xml'));

write_config_to_xml(app_path,curr_disp,algos);
close(path_fig);
end