function app_path=app_path_create(varargin)


if isdeployed % Stand-alone mode.
    [~, result] = system('path');
    app_path_main = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
else % MATLAB mode.
    temp_path=which('EchoAnalysis');
    idx_temp=strfind(temp_path,'\');
    app_path_main=temp_path(1:idx_temp(end));
end


app_path_data=fullfile(tempdir,'data_echo');
app_path_cvs_root=':local:Z:\';
app_path_data_root='X:\';


p = inputParser;

addParameter(p,'main',app_path_main,@ischar);
addParameter(p,'data',app_path_data,@ischar);
addParameter(p,'cvs_root',app_path_cvs_root,@ischar);
addParameter(p,'data_root',app_path_data_root,@ischar);


parse(p,varargin{:});

results=p.Results;
props=fieldnames(results);

for i=1:length(props)
    if isnumeric(results.(props{i}))
        app_path.(props{i})=double(results.(props{i}));
    else
        app_path.(props{i})=(results.(props{i}));
    end
    
end

end