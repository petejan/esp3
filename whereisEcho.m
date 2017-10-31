%% whereisEcho.m
%
% Returns ESP3's path (where it's being run)
%
%% Help
%
% *USE*
%
% Just checks whether the version is deployed or as Matlab code and applie
% simple code to determine current path.
%
% *INPUT VARIABLES*
%
% NA
%
% *OUTPUT VARIABLES*
%
% * |app_path_main|: ESP3's path (char).
%
% *RESEARCH NOTES*
%
% NA
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2017-03-02: commented and header added (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
%   app_path_main = whereisEcho();
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function app_path_main = whereisEcho()


if isdeployed % Stand-alone mode.
    
    [~, result] = system('path');
    app_path_main = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    
else % MATLAB mode.
    
    % get full path and filename for the main function
    app_path_main=fileparts(which('EchoAnalysis'));
    
end


end