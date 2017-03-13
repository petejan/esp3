function remove_interactions(main_figure)
% remove_interactions(main_figure)
%
% DESCRIPTION
%
% Remove user interactions with main figure
%
% USE
%
% This function makes the main figure unresponsive to any user input
% (clicking mouse, pressing a keyboard key, using the mouse scroll, etc.).
% To be used when loading new stuff (see loadEcho.m)
%
% PROCESSING SUMMARY
%
% - Set Pointer to Arrow
% - Making mouse button press irrelevant
% - Making keyboard key press irrelevant
% - Making mouse scroll irrelevant
% - Making mouse pointer movement irrelevant
%
% INPUT VARIABLES
%
% - main_figure (required): ESP3 main figure
%
% RESEARCH NOTES
%
% NEW FEATURES
%
% 2017-03-02: first version.
%
%%%
% Yoann Ladroit, NIWA.
%%%

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