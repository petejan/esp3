function EchoAnalysis(varargin)
global DEBUG;
DEBUG=0;

%%%%%%%%%%%%%% main_figure is the handle to the main window of the App %%%%
%%%%%%%%%%%%%%
size_max=get(0,'ScreenSize');
main_figure=figure('Visible','off',...
    'Units','pixels','Position',[0 100 size_max(3)/4*3 size_max(4)/4*3],...       %Position and size normalized to the screen size ([left, bottom, width, height])
    'Color','White',...                                         %Background color
    'Name','Echo Analysis','NumberTitle','off',...    %GUI Name
    'Resize','on',...
    'MenuBar','none',...'%No Matlab Menu
    'visible','off',...
    'CloseRequestFcn',@closefcn_clean);
%     'SizeChangedFcn',@resize_main_fig);%Causing to much issues. Replaced
%     withe the following...


set(0,'DefaultUicontrolFontSize',10);%Default font size for Controls
set(0,'DefaultUipanelFontSize',10);%Default font size for Panels



app_path=app_path_create();

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
    choice = questdlg('There is files your EchoAnalysis temp folder, do you want to delete them?', ...
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
            if exist(fullfile(app_path.data,files_in_temp(idx_old(i)).name),'file')==2
                delete(fullfile(app_path.data,files_in_temp(idx_old(i)).name));
            end
        end
    end
end


layer_obj=[];
curr_disp_obj=curr_state_disp_cl();
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
catch err
   disp(err.message);
end
end

% 
% function resize_main_fig(main_figure,~)
% set(main_figure,'SizeChangedFcn','')
% figwidth = main_figure.Position(3);
% figheight = main_figure.Position(4);
% 
% size_max=get(0,'ScreenSize');
% if figwidth<(size_max(3)/4*3);
%     main_figure.Position(3)=size_max(3)/4*3;
% end
% if figheight<(size_max(4)/4*3);
%     main_figure.Position(4)=size_max(4)/4*3;
% end
% set(main_figure,'SizeChangedFcn',@resize_main_fig);
% end

