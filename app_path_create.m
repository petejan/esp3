function app_path=app_path_create(varargin)

app_path_data_temp=fullfile(tempdir,'data_echo');
app_path_cvs_root=':local:Z:\';
app_path_data_root=fullfile(whereisEcho,'example_data');
app_path_data=fullfile(whereisEcho,'example_data');
app_path_scripts=fullfile(whereisEcho,'echo_scripts');
app_path_results=fullfile(whereisEcho,'echo_result');
p = inputParser;

addParameter(p,'data_temp',app_path_data_temp,@ischar);
addParameter(p,'cvs_root',app_path_cvs_root,@ischar);
addParameter(p,'data_root',app_path_data_root,@ischar);
addParameter(p,'data',app_path_data,@ischar);
addParameter(p,'scripts',app_path_scripts,@ischar);
addParameter(p,'results',app_path_results,@ischar);

parse(p,varargin{:});

results=p.Results;
props=fieldnames(results);

for i=1:length(props)
    app_path.(props{i})=(results.(props{i}));
    if ~strcmpi(props(i),'cvs_root')
        if ~isdir(app_path.(props{i}))
            try
                mkdir(app_path.(props{i}));
            catch
                fprintf('Could not create path %s\n',app_path.(props{i}));
            end
        end
    end
end





end