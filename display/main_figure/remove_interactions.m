function remove_interactions(main_figure)
% remove_interactions(main_figure)
%
% DESCRIPTION
%
% Remove user interactions with main figure
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
% 2017-03-13: first version. 
% 
%%% 
% Yoann Ladroit, NIWA.
%%%


% Set Pointer to Arrow
set(main_figure,'Pointer','arrow');

% Initialize Mouse interactions in the figure
set(main_figure,'WindowButtonDownFcn','');

% Initialize Keyboard interactions in the figure
set(main_figure,'KeyPressFcn','');

%Set wheel mouse scroll cback
set(main_figure,'WindowScrollWheelFcn','');

%Set pointer motion cback
set(main_figure,'WindowButtonMotionFcn','');





end