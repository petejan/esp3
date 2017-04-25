%% remove_alt_interactions.m
%
% Remove secondary user interactions with main figure
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
function remove_alt_interactions(main_figure)

                % interactions.WindowButtonUpFcn(2)=iptaddcallback(main_figure,'WindowButtonDownFcn', @wbucb);
                % interactions.WindowButtonMotionFcn(2)=iptaddcallback(main_figure,'WindowButtonMotionFcn', @wbmcb);

interactions=getappdata(main_figure,'interaction_str');


% Making secondary mouse button press irrelevant
iptremovecallback(main_figure,'WindowButtonDownFcn', interactions.WindowButtonDownFcn(2));
interactions.WindowButtonDownFcn(2)=nan;


% Making secondary keyboard key press irrelevant
iptremovecallback(main_figure,'KeyPressFcn', interactions.KeyPressFcn(2));
interactions.KeyPressFcn(2)=nan;


% Making secondary mouse pointer movement irrelevant
iptremovecallback(main_figure,'WindowButtonMotionFcn', interactions.WindowButtonMotionFcn(2));
interactions.WindowButtonMotionFcn(2)=nan;

setappdata(main_figure,'interaction_str',interactions);



end