function initialize_interactions(main_figure)
% initialize_interactions(main_figure)
% 
% DESCRIPTION 
% 
% Initialize user interactions with main figure
% 
% USE 
% 
% [A bit more detailed description of how to use the function. DELETE THIS LINE IF UNUSED]
% 
% PROCESSING SUMMARY 
% 
% - [Bullet point list summary of the steps in the processing.]
% - [DELETE THESE LINES IF UNUSED]
% 
% INPUT VARIABLES 
% 
% - [Bullet point list description of input variables.] 
% - [Describe if required, optional or parameters..]
% - [.. what are the valid values and what they do.]
% - [DELETE THESE LINES IF UNUSED]
% 
% OUTPUT VARIABLES 
% 
% - [Bullet point list description of output variables.]
% - [DELETE THESE LINES IF UNUSED]
% 
% RESEARCH NOTES 
% 
% [Describes what features are temporary or needed future developments.]
% [Also use for paper references.]
% [DELETE THESE LINES IF UNUSED]
% 
% NEW FEATURES 
% 
% 2017-03-02: first version. 
% 
% 
%%% 
% [Yoann Ladroit NIWA]
%%% 


% Set Pointer to Arrow
set(main_figure,'Pointer','arrow');

% Initialize Mouse interactions in the figure
set(main_figure,'WindowButtonDownFcn',@(src,envdata)select_area_cback(src,envdata,main_figure));

% Initialize Keyboard interactions in the figure
set(main_figure,'KeyPressFcn',{@keyboard_func,main_figure});

%Set wheel mouse scroll cback
set(main_figure,'WindowScrollWheelFcn',{@scroll_fcn_callback,main_figure});

%Set pointer motion cback
set(main_figure,'WindowButtonMotionFcn',{@display_info_ButtonMotionFcn,main_figure,0});

size_max = get(0, 'MonitorPositions');

try
    javaFrame = get(main_figure,'JavaFrame');
    % Set minimum size of the figure
    jProx = javaFrame.fHG2Client.getWindow;
    jProx.setMinimumSize(java.awt.Dimension(size_max(1,3)/4*3,size_max(1,4)/4*3));
    setappdata(main_figure,'javaWindow',jProx);
    %jFrame.setMaximized(true);
    
    % Create drag and drop for the figure object
    jObj = javaFrame.getFigurePanelContainer();
    dndcontrol.initJava();
    dndobj = dndcontrol(jObj);
    % Set Drop callback functions
    dndobj.DropFileFcn = @fileDropFcn;
    dndobj.DropStringFcn = '';
    setappdata(main_figure,'Dndobj',dndobj);
catch err
    disp(err.message);
end

% nested function for above dndobj
    function fileDropFcn(~,evt)
        open_dropped_file(evt,main_figure);
    end
end