%% replace_interaction.m
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
%replace_interaction(main_figure,'interaction','WindowButtonDownFcn','id',1,'interaction_fcn',{@zoom_in_callback,main_figure},'pointer','glassplus');
function replace_interaction(main_figure,varargin)

interact_fields={'WindowButtonDownFcn',...
    'WindowButtonMotionFcn',...
    'WindowButtonUpFcn',...
    'WindowKeyPressFcn',...
    'KeyPressFcn',...
    'WindowKeyReleaseFcn',...
    'WindowScrollWheelFcn'};

p = inputParser;

addRequired(p,'main_figure',@ishandle);
addParameter(p,'interaction','WindowButtonDownFcn',@(x) ismember(x,interact_fields));
addParameter(p,'id',1,@(x) ismember(x,[1 2]));
addParameter(p,'interaction_fcn',[],@(x) isempty(x)||isa(x,'function_handle')||iscell(x));
addParameter(p,'pointer',main_figure.Pointer,@ischar)

parse(p,main_figure,varargin{:});

interactions_id=getappdata(main_figure,'interactions_id');

if isempty(interactions_id)
    return;
end

iptremovecallback(main_figure,p.Results.interaction,interactions_id.(p.Results.interaction)(p.Results.id));

if isempty(p.Results.interaction_fcn)
    fcn=' ';
else
    fcn=p.Results.interaction_fcn;
end
interactions_id.(p.Results.interaction)(p.Results.id)=iptaddcallback(main_figure,(p.Results.interaction),fcn);
setptr(main_figure,p.Results.pointer);

setappdata(main_figure,'interactions_id',interactions_id);

end