function app_path_main = whereisEcho()
% app_path_main = whereisEcho()
%
% DESCRIPTION
%
% Returns ESP3's path (where it's being run)
%
% USE
%
% Just checks whether the version is deployed or as Matlab code and applie
% simple code to determine current path.
%
% OUTPUT VARIABLES
%
% - app_path_main (char): ESP3's path
%
% RESEARCH NOTES
%
% NA
%
% NEW FEATURES
%
% 2017-03-02: commented and header added (Alex)
%
% EXAMPLE
%
% app_path_main = whereisEcho();
%
%%%
% Yoann Ladroit, NIWA
%%%

if isdeployed % Stand-alone mode.
    
    [~, result] = system('path');
    app_path_main = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    
else % MATLAB mode.
    
    % get full path and filename for the main function
    temp_path=which('EchoAnalysis');
    
    % keep only the path
    idx_temp=strfind(temp_path,'\');
    app_path_main=temp_path(1:idx_temp(end));
    
end



end