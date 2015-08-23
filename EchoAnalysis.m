function EchoAnalysis(varargin)
global DEBUG;
DEBUG=0;

%%%%%%%%%%%%%% main_figure is the handle to the main window of the App %%%%
%%%%%%%%%%%%%%
main_figure=figure('Visible','off',...
    'Units','pixels','Position',[100 100 1280 720],...       %Position and size normalized to the screen size ([left, bottom, width, height])
    'Color','White',...                                         %Background color
    'Name','Echo Analysis','NumberTitle','off',...    %GUI Name
    'Resize','on',...
    'MenuBar','none',...'%No Matlab Menu
    'visible','off',...
    'CloseRequestFcn',@closefcn_clean,...
    'SizeChangedFcn',@resize_main_fig);

set(0,'DefaultUicontrolFontSize',10);%Default font size for Controls
set(0,'DefaultUipanelFontSize',10);%Default font size for Panels

set(main_figure,'KeyPressFcn',{@keyboard_func,main_figure});


if isdeployed
    temp_path=ctfroot;
else
    temp_path=which('EchoAnalysis');
end

idx_temp=strfind(temp_path,'\');
app_path.main=temp_path(1:idx_temp(end));
app_path.data=fullfile(tempdir,'data_echo');
app_path.cal=[];
app_path.cal_eba=[];

if ~isdeployed
    update_path(app_path.main);
end

if ~isdir(app_path.data)
    mkdir(app_path.data);
    disp('Data Folder Created')
    disp(app_path.data)
end

files_in_temp=dir(fullfile(app_path.data,'*.bin'));

idx_old=[];
for uu=1:length(files_in_temp)
    if (now-files_in_temp(uu).datenum)>1
        idx_old=[idx_old uu];
    end
end

if ~isempty(idx_old)
    delete_files=0;
    choice = questdlg('There is files older than 1 day in your EchoAnalysis temp folder, do you want to delete them?', ...
        'Delete files?',...
        'Yes','No', ...
        'No');
    
    switch choice
        case 'Yes'
            delete_files=1;
        case 'No'
            delete_files=0;
    end
    
    if isempty(choice)
        return;
    end
    
    if delete_files==1
        for i=1:length(idx_old)
            delete(fullfile(app_path.data,files_in_temp(idx_old(i)).name));
        end
    end
end


layer_obj=layer_cl();
curr_disp_obj=curr_state_disp_cl();
process_obj=process_cl.empty;

layers=layer_obj;
setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Layer',layer_obj);
setappdata(main_figure,'Curr_disp',curr_disp_obj);
setappdata(main_figure,'App_path',app_path);
setappdata(main_figure,'Process',process_obj);

movegui(main_figure,'center')

initialize_display(main_figure);
update_display(main_figure,1);

end


function resize_main_fig(main_figure,~)
figwidth = main_figure.Position(3);
figheight = main_figure.Position(4);

if figwidth<1280
    main_figure.Position(3)=1280;
end
if figheight<720
    main_figure.Position(4)=720;
end
%movegui(main_figure,'center');

end

function update_path(path)
addpath(path);
addpath(genpath(fullfile([path 'acoustic'])));
addpath(genpath(fullfile([path 'algo'])));
addpath(genpath(fullfile([path 'display'])));
addpath(genpath(fullfile([path 'esp2'])));
addpath(genpath(fullfile([path 'export'])));
addpath(genpath(fullfile([path 'fileIO'])));
addpath(genpath(fullfile([path 'icons'])));
addpath(genpath(fullfile([path 'general'])));
addpath(genpath(fullfile([path 'mapping'])));
addpath(genpath(fullfile([path 'mbs'])));
addpath(genpath(fullfile([path 'signal_processing'])));
end

