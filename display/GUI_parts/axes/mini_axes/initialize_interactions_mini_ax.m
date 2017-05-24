%% initialize_interactions_mini_ax.m
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
% * |mini_axes_fig|: Handle to main ESP3 window (Required).
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
% * 2017-05-22: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function initialize_interactions_mini_ax(mini_axes_fig,main_figure)

interactions=getappdata(mini_axes_fig,'interactions_id');

if isempty(interactions)
    interactions.WindowButtonDownFcn=nan(1,2);
    interactions.WindowButtonMotionFcn=nan(1,2);
    interactions.WindowButtonUpFcn=nan(1,2);
    interactions.WindowKeyPressFcn=nan(1,2);
    interactions.KeyPressFcn=nan(1,2);
    interactions.WindowKeyReleaseFcn=nan(1,2);
    interactions.KeyReleaseFcn=nan(1,2);
    interactions.WindowScrollWheelFcn=nan(1,2);
end

field_interaction=fieldnames(interactions);

for i=1:numel(field_interaction)
   for ir=1:numel(interactions.(field_interaction{i}))
       iptremovecallback(mini_axes_fig,field_interaction{i}, interactions.(field_interaction{i})(ir));
       interactions.(field_interaction{i})(ir)=nan;
   end
end

%%% Set Interactions

% Pointer to Arrow
setptr(mini_axes_fig,'arrow');

% Set wheel mouse scroll cback
interactions.WindowScrollWheelFcn(1)=iptaddcallback(mini_axes_fig,'WindowScrollWheelFcn',{@scroll_fcn_callback,main_figure});

% Initialize Keyboard interactions in the figure
interactions.KeyPressFcn(1)=iptaddcallback(mini_axes_fig,'KeyPressFcn',{@keyboard_func,main_figure});

setappdata(mini_axes_fig,'interactions_id',interactions);

end