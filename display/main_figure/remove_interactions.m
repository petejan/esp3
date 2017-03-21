%% remove_interactions.m
%
% Remove user interactions with main figure
%
%% Help
%
% *USE*
%
% This function makes the main figure unresponsive to any user input
% (clicking mouse, pressing a keyboard key, using the mouse scroll, etc.).
% To be used when loading new stuff (see loadEcho.m)
%
% *INPUT VARIABLES*
%
% * |main_figure|: Handle to main ESP3 window (Required).
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
function remove_interactions(main_figure)


% Set Pointer to Arrow
set(main_figure,'Pointer','arrow');

% Making mouse button press irrelevant
set(main_figure,'WindowButtonDownFcn','');

% Making keyboard key press irrelevant
set(main_figure,'KeyPressFcn','');

% Making mouse scroll irrelevant
set(main_figure,'WindowScrollWheelFcn','');

% Making mouse pointer movement irrelevant
set(main_figure,'WindowButtonMotionFcn','');





end