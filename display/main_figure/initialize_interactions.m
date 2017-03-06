function initialize_interactions(main_figure,new)
% initialize_interactions(main_figure)
<<<<<<< HEAD
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
% - main_figure (required): ESP3 main figure
% - new: 0 or 1. 0 if refreshing 1 if first time you are loading
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
%%%
=======
% 
% DESCRIPTION 
% 
% Initialize user interactions with ESP3 main figure
% 
% USE 
% 
% [This section contains a more detailed description of what the function does and how to use it, for the interested user to have an overall understanding of its function] 
% This is a text file containing the basic comment template to add at the
% start of any new ESP3 function to serve as function help. 
% [REPLACE THESE LINES WITH ACTUAL CONTENT OR DELETE IF UNUSED]
% 
% PROCESSING SUMMARY 
% 
% [This section contains bullet point list of major processing steps, for the very interested user to have a clear understanding of the function works before reading its details]
% - Function does this first
% - Then it does this
% [REPLACE THESE LINES WITH ACTUAL CONTENT OR DELETE IF UNUSED]
% 
% INPUT VARIABLES 
% 
% - main_figure (required): ESP3 main figure
% 
% RESEARCH NOTES 
% 
% [This section describes what features are temporary, needed future developments and paper references.]
% [REPLACE THESE LINES WITH ACTUAL CONTENT OR DELETE IF UNUSED]
% 
% NEW FEATURES 
% 
% 2017-03-02: first version. 
% 
%%% 
>>>>>>> b34623d06e293d3bf0bd1fdb788fee6bbab3525c
% Yoann Ladroit, NIWA.
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


if new
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
end

% nested function for above dndobj
    function fileDropFcn(~,evt)
        open_dropped_file(evt,main_figure);
    end
end