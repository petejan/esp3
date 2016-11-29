function EchoAnalysis(varargin)
global DEBUG;
DEBUG=0;
javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

p = inputParser;

addParameter(p,'Filenames',{},@(x) ischar(x)|iscell(x));
addParameter(p,'SaveEcho',0,@isnumeric);

parse(p,varargin{:});



%%%%%%%%%%%%%% main_figure is the handle to the main window of the App %%%%
%%%%%%%%%%%%%%
size_max = get(0, 'MonitorPositions');
main_figure=figure('Visible','on',...
    'Units','pixels','Position',[size_max(1,1) size_max(1,2)+1/8*size_max(1,4) size_max(1,3) size_max(1,4)/8*7],...       %Position and size normalized to the screen size ([left, bottom, width, height])
    'Color','White',...                                         %Background color
    'Name','ESP3',...
    'NumberTitle','off',...   
    'Resize','on',...
    'MenuBar','none',...
    'visible','off',...
    'DockControls','off',...
    'CloseRequestFcn',@closefcn_clean);


javaFrame = get(main_figure,'JavaFrame');
javaFrame.setFigureIcon(javax.swing.ImageIcon(fullfile(whereisEcho(),'icons','echoanalysis.png')));

set(main_figure,'WindowScrollWheelFcn',{@scroll_fcn_callback,main_figure});

echo_ver=get_ver();
fprintf('Version %s\n',echo_ver);

set(0,'DefaultUicontrolFontSize',10);%Default font size for Controls
set(0,'DefaultUipanelFontSize',10);%Default font size for Panels

main_path=whereisEcho();

if ~isdeployed
    update_path(main_path);
end

[app_path,curr_disp_obj,~]=load_config_from_xml(fullfile(main_path,'config','config_echo.xml'));

try
    if ~isdir(app_path.data_temp)
        mkdir(app_path.data_temp);
        disp('Data Folder Created')
        disp(app_path.data_temp)
    end
catch 
    disp('Error: Unable to create Data Folder')
    disp(app_path.data_temp);
    disp('Creating new config_echo.xml file')
    delete(fullfile(main_path,'config','config_echo.xml'));
    [app_path,curr_disp_obj,~]=load_config_from_xml(fullfile(main_path,'config','config_echo.xml'));
end


files_in_temp=dir(fullfile(app_path.data_temp,'*.bin'));

idx_old=[];
for uu=1:length(files_in_temp)
    if (now-files_in_temp(uu).datenum)>1
        idx_old=union(idx_old,uu);
    end
end

if ~isempty(idx_old)
    delete_files=0;
    choice = questdlg('There are files your ESP3 temp folder, do you want to delete them?', ...
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
            if exist(fullfile(app_path.data_temp,files_in_temp(idx_old(i)).name),'file')==2
                delete(fullfile(app_path.data_temp,files_in_temp(idx_old(i)).name));
            end
        end
    end
end


layer_obj=layer_cl.empty;

process_obj=process_cl.empty;

layers=layer_obj;
setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Layer',layer_obj);
setappdata(main_figure,'Curr_disp',curr_disp_obj);
setappdata(main_figure,'App_path',app_path);
setappdata(main_figure,'Process',process_obj);
setappdata(main_figure,'ExternalFigures',matlab.ui.Figure.empty());
movegui(main_figure,'center');

initialize_display(main_figure);
set(main_figure,'KeyPressFcn',{@keyboard_func,main_figure});


try
    jFrame = get(handle(main_figure), 'JavaFrame');
    jProx = jFrame.fHG2Client.getWindow;
    jProx.setMinimumSize(java.awt.Dimension(size_max(1,3)/4*3,size_max(1,4)/4*3));
    setappdata(main_figure,'javaWindow',jProx);
    %jFrame.setMaximized(true);
catch err
    disp(err.message);
end


if ~isempty(p.Results.Filenames)
    open_file([],[],p.Results.Filenames,main_figure);
    if p.Results.SaveEcho>0
        save_echo(main_figure);
        cleanup_echo(main_figure);
        delete(main_figure);
    end
end


end


