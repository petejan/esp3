function app_path_main=whereisEcho()


if isdeployed % Stand-alone mode.
    [~, result] = system('path');
    app_path_main = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
else % MATLAB mode.
    temp_path=which('EchoAnalysis');
    idx_temp=strfind(temp_path,'\');
    app_path_main=temp_path(1:idx_temp(end));
end

end