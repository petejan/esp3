%% initialize_interactions_v2.m
%
% Initialize user interactions with ESP3 main figure, new version, in
% developpement
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
% * 2017-04-25: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function initialize_interactions_v2(main_figure,new)

interactions=getappdata(main_figure,'interactions_id');

if isempty(interactions)
    interactions.WindowButtonDownFcn=nan(1,2);
    interactions.WindowButtonMotionFcn=nan(1,2);
    interactions. WindowButtonUpFcn=nan(1,2);
    interactions.WindowKeyPressFcn=nan(1,2);
    interactions.WindowKeyReleaseFcn=nan(1,2);
    interactions.WindowScrollWheelFcn=nan(1,2);
end

field_interaction=fieldnames(interactions);

for i=1:numel(field_interaction)
   for ir=1:numel(interactions.(field_interaction{i}))
       iptremovecallback(main_figure,field_interaction{i}, interactions.(field_interaction{i})(ir));
       interactions.(field_interaction{i})(ir)=nan;
   end
end

%%% Set Interactions

% Pointer to Arrow
set(main_figure,'Pointer','arrow');

% Initialize Mouse interactions in the figure
interactions.WindowButtonUpFcn(1)=iptaddcallback(main_figure,'WindowButtonDownFcn',@(src,envdata)select_area_cback(src,envdata,main_figure));

% Initialize Keyboard interactions in the figure
interactions.KeyPressFcn(1)=iptaddcallback(main_figure,'KeyPressFcn',{@keyboard_func,main_figure});

% Set wheel mouse scroll cback
interactions.WindowScrollWheelFcn(1)=iptaddcallback(main_figure,'WindowScrollWheelFcn',{@scroll_fcn_callback,main_figure});

% Set pointer motion cback
interactions.WindowButtonMotionFcn(1)=iptaddcallback(main_figure,'WindowButtonMotionFcn',{@display_info_ButtonMotionFcn,main_figure,0});

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

setappdata(main_figure,'interactions_id',interactions);

end