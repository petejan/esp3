function echo_ver=get_ver()

echo_ver='0.0.0.0 Do not use for integration';
file_ver=fullfile(whereisEcho(),'ver.dat');
if exist(file_ver,'file')==2
    res_ini = ini2struct(file_ver);
    if isfield(res_ini,'header')
        if isfield(res_ini.header,'version')
            echo_ver=res_ini.header.version;  
        end
    end
end