%% init_java_fcn(main_figure).m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |input_variable_1|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |output_variable_1|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-0522: first version (Yoann Ladroit).
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function init_java_fcn(main_figure)
%%% Java stuff in case of first-time loading

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