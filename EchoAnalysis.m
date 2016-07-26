function EchoAnalysis(varargin)
global DEBUG;
DEBUG=0;
%set the lookand feel of the figure
javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');


p = inputParser;

addParameter(p,'Filenames',{},@(x) ischar(x)|iscell(x));

parse(p,varargin{:});



%%%%%%%%%%%%%% main_figure is the handle to the main window of the App %%%%
%%%%%%%%%%%%%%
size_max=get(0,'ScreenSize');
main_figure=figure('Visible','on',...
    'Units','pixels','Position',[0 100 size_max(3) size_max(4)/8*7],...       %Position and size normalized to the screen size ([left, bottom, width, height])
    'Color','White',...                                         %Background color
    'Name','Echo Analysis','NumberTitle','off',...    %GUI Name
    'Resize','on',...
    'MenuBar','none',...'%No Matlab Menu
    'visible','off',...
    'CloseRequestFcn',@closefcn_clean);

git_ver='$Id:$';

git_ver = regexprep(git_ver, '[^\d]', '');
if isempty(git_ver)
    git_ver = 'unknown';
end
fprintf('Version %s\n',git_ver);


set(0,'DefaultUicontrolFontSize',10);%Default font size for Controls
set(0,'DefaultUipanelFontSize',10);%Default font size for Panels

main_path=whereisEcho();

if ~isdeployed    
    update_path(main_path);
end

[app_path,curr_disp_obj,~]=load_config_from_xml(fullfile(main_path,'config_echo.xml'));

try
    if ~isdir(app_path.data_temp)
        mkdir(app_path.data_temp);
        disp('Data Folder Created')
        disp(app_path.data_temp)
    end
catch ME
    disp('Error: Unable to create Data Folder')
    disp(app_path.data_temp)
    disp('Creating new config_echo.xml file')
    delete(fullfile(main_path,'config_echo.xml'));
    [app_path,curr_disp_obj,~]=load_config_from_xml(fullfile(main_path,'config_echo.xml')); %#ok<ASGLU>
    disp('Please re-launch program and change Data Folder path')
    rethrow(ME);
end


files_in_temp=dir(fullfile(app_path.data_temp,'*.bin'));

idx_old=[];
for uu=1:length(files_in_temp)
    if (now-files_in_temp(uu).datenum)>1
        idx_old=[idx_old uu];
    end
end

if ~isempty(idx_old)
    delete_files=0;
    choice = questdlg('There are files your EchoAnalysis temp folder, do you want to delete them?', ...
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
setappdata(main_figure,'ExternalFigures',[]);
movegui(main_figure,'center')
initialize_display(main_figure);
init_listeners(main_figure);
set(main_figure,'KeyPressFcn',{@keyboard_func,main_figure});
drawnow;

try
    jFrame = get(handle(main_figure), 'JavaFrame');
    jProx = jFrame.fHG2Client.getWindow;
    jProx.setMinimumSize(java.awt.Dimension(size_max(3)/4*3,size_max(4)/4*3));
    setappdata(main_figure,'javaWindow',jProx);
catch err
   disp(err.message);
end

create_menu(main_figure);
if ~isempty(p.Results.Filenames)
   open_file([],[],p.Results.Filenames,main_figure);
end
end


