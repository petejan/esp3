%% EchoAnalysis.m
%
% ESP3 Main function
%
%          |
%         /|\
%        / | \
%       /  |  \
%      /   |___\   
%    _/____|______   
%     \___________\   written by Yoann Ladroit
%        / \          in 2016
%       /   \
%      / <>< \    Fisheries Acoustics
%     /<>< <><\   NIWA - National Institute of Water & Atmospheric Research
%
%% Help
%
% *USE*
%
% Run this function without input variables to launch empty ESP3, or with
% input file names to open. Use the SaveEcho optional parameter to print
% out contents of any input file.
%
% *INPUT VARIABLES*
%
% * 'Filenames': Filenames to load (Optional. char or cell).
% * 'SaveEcho': Flag to print window (Optional. If |1|, print content of
% input file and closes ESP3).
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% NA
%
% *NEW FEATURES*
%
% * 2017-03-22: reformatting header according to new template (Alex Schimel)
% * 2017-03-17: reformatting comment and header for compatibility with publish (Alex Schimel)
% * 2017-03-02: commented and header added (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
%   EchoAnalysis; % launches ESP3
%   EchoAnalysis('my_file.raw'); % launches ESP3 and opens 'my_file.raw'.
%   EchoAnalysis('my_file.raw',1); % launches ESP3, opens 'my_file.raw', print file data to .png, and close ESP3.
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA.
%
% Copyright 2017 NIWA
% 
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions: The above copyright notice and this permission
% notice shall be included in all copies or substantial portions of the
% Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
%

%% Function
function EchoAnalysis(varargin)


%% Debug
global DEBUG;
DEBUG=0;

%% Default font size for Controls and Panels and db prefs
set(0,'DefaultUicontrolFontSize',10);
set(0,'DefaultUipanelFontSize',11);
setdbprefs('DataReturnFormat','table');

%% Set java window style and remove Javaframe warning
if ispc
    javax.swing.UIManager.setLookAndFeel('com.sun.java.swing.plaf.windows.WindowsLookAndFeel');
end
warning('off','MATLAB:HandleGraphics:ObsoletedProperty:JavaFrame');

desktop = com.mathworks.mde.desk.MLDesktop.getInstance;
desktop.addGroup('ESP3');
desktop.addGroup('Regions');
desktop.addGroup('Logbook');


%% Checking and parsing input variables
p = inputParser;
addOptional(p,'Filenames',{},@(x) ischar(x)|iscell(x));
addOptional(p,'SaveEcho',0,@isnumeric);
parse(p,varargin{:});

%% Do not Relaunch ESP3 if already open (in Matlab)...
if ~isdeployed()
    esp_win = findobj(groot,'tag','ESP3');
    if~isempty(esp_win)
        figure(esp_win);
        return;
    end
end
%% Software main path
main_path = whereisEcho();
if ~isdeployed
    update_path(main_path);
end
update_java_path(main_path);

%% Get monitor's dimensions
size_max = get(0, 'MonitorPositions');

%% Defining the app's main window
main_figure = figure('Units','pixels',...
                     'Position',[size_max(1,1) size_max(1,2)+1/8*size_max(1,4) size_max(1,3)/4*3 size_max(1,4)/4*3],... %Position and size normalized to the screen size ([left, bottom, width, height])
                     'Color','White',...
                     'Name','ESP3',...
                     'Tag','ESP3',...
                     'NumberTitle','off',...   
                     'Resize','on',...
                     'MenuBar','none',...
                     'Toolbar','none',...
                     'visible','off',...
                     'WindowStyle','normal',...
                     'ResizeFcn',@resize_echo,...
                     'CloseRequestFcn',@closefcn_clean);
                 
%% Install mouse pointer manager in figure
iptPointerManager(main_figure);

%% Get Javaframe from Figure to set the Icon
if ispc
    javaFrame = get(main_figure,'JavaFrame');
    javaFrame.fHG2Client.setClientDockable(true);
    set(javaFrame,'GroupName','ESP3');
    javaFrame.setFigureIcon(javax.swing.ImageIcon(fullfile(whereisEcho(),'icons','echoanalysis.png')));
end

%% Check if GPU computation is available %%
gpu_comp=get_gpu_comp_stat();
if gpu_comp
    disp('GPU computation Available');
else
    disp('GPU computation Unavailable');
end

%% Read ESP3 config file
[app_path,curr_disp_obj,~,~] = load_config_from_xml_v2(1,1,1);

%% Create temporary data folder
try
    if ~isdir(app_path.data_temp)
        mkdir(app_path.data_temp);
        disp('Data Temp Folder Created')
        disp(app_path.data_temp)
    end   
catch 
    disp('creating new config_path.xml file with standard path and options')
    [~,path_config_file,~]=get_config_files();
    delete(path_config_file);
    [app_path,~,~,~] = load_config_from_xml_v2(1,0,0);
end

%% Managing existing files in temporary data folder
files_in_temp=dir(fullfile(app_path.data_temp,'*.bin'));

% idx_old=[];
% for uu=1:numel(files_in_temp)
%     if (now-files_in_temp(uu).datenum)>1
%         idx_old = union(idx_old,uu);
%     end
% end

idx_old=1:numel(files_in_temp);%check all temp files...

if ~isempty(idx_old)
    
    % by default, don't delete
    delete_files=0;
    
    choice = questdlg('There are files in your ESP3 temp folder, do you want to delete them?','Delete files?','Yes','No','No');
    
    switch choice
        case 'Yes'
            delete_files = 1;
        case 'No'
            delete_files = 0;
    end
    
    if isempty(choice)
        delete_files = 0;
    end
    
    if delete_files == 1
        for i = 1:numel(idx_old)
            if exist(fullfile(app_path.data_temp,files_in_temp(idx_old(i)).name),'file') == 2
                delete(fullfile(app_path.data_temp,files_in_temp(idx_old(i)).name));
            end
        end
    end
    
end

%% Initialize empty layer, process and layers objects
layer_obj=layer_cl.empty();
process_obj=process_cl.empty();
layers=layer_obj;

%% Store objects in app main figure
setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Layer',layer_obj);
setappdata(main_figure,'Curr_disp',curr_disp_obj);
setappdata(main_figure,'App_path',app_path);
setappdata(main_figure,'Process',process_obj);

setappdata(main_figure,'ExternalFigures',matlab.ui.Figure.empty())
switch curr_disp_obj.DispBadTrans
    case 'off'
        alpha_bt=0;
    case 'on'
        alpha_bt=0.6;
end
switch curr_disp_obj.DispReg
    case 'off'
        alpha_reg=0;
    case 'on'
        alpha_reg=0.4;
end

main_figure.Alphamap=[0 (1-curr_disp_obj.UnderBotTransparency/100) alpha_bt alpha_reg 1];

%% Initialize the display and the interactions with the user
initialize_display(main_figure);
initialize_interactions_v2(main_figure);
init_java_fcn(main_figure);
update_cursor_tool(main_figure)
init_listeners(main_figure);

%% If files were loaded in input, load them now
if ~isempty(p.Results.Filenames)
    open_file([],[],p.Results.Filenames,main_figure);
    % If request was made to print display: print and close ESP3
    if p.Results.SaveEcho>0
        save_echo(main_figure,[],[]);
        cleanup_echo(main_figure);
        delete(main_figure);
    end
end
%% Software version
new_version_figure(main_figure);


end





