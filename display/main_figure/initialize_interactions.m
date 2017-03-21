%% initialize_interactions.m
%
% Initialize user interactions with ESP3 main figure
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |main_figure|: Handle to main ESP3 window (Required).
% * |new|: Flag for refreshing or first time load (Required. |0| if
% refreshing or |1| if first-time loading).
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2017-03-02: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function initialize_interactions(main_figure,new)

%%% Set Interactions

% Pointer to Arrow
set(main_figure,'Pointer','arrow');

% Initialize Mouse interactions in the figure
set(main_figure,'WindowButtonDownFcn',@(src,envdata)select_area_cback(src,envdata,main_figure));

% Initialize Keyboard interactions in the figure
set(main_figure,'KeyPressFcn',{@keyboard_func,main_figure});

% Set wheel mouse scroll cback
set(main_figure,'WindowScrollWheelFcn',{@scroll_fcn_callback,main_figure});

% Set pointer motion cback
set(main_figure,'WindowButtonMotionFcn',{@display_info_ButtonMotionFcn,main_figure,0});

%%% Java stuff in case of first-time loading 
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