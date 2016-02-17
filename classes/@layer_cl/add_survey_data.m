function add_survey_data(layer,survey_vec,files_csv)

str_data_csv=cell(1,length(survey_vec));

for iiu=1:length(survey_vec)
    str_data_csv{iiu}= survey_vec(iiu).print_survey_data();
end


files_layer=layer.Filename;
idx_files=[];
for u=1:length(files_layer)
    idx_files=union(idx_files,find(strcmpi(files_layer{u},files_csv)));
end
str_data=cell(1,length(idx_files));
diff=[];
incomplete=[];
to_load=[];
for ii=1:length(idx_files)
    str_data{ii}=survey_vec(idx_files(ii)).print_survey_data();
    if ~strcmpi(str_data{1},str_data{ii})
        diff=[diff '\n' str_data{ii}];
    end
    
    idx_incomp=strcmpi(str_data{ii},str_data_csv);
    if (length(idx_files)~=length(idx_incomp));
        incomplete=[incomplete '\n' str_data{ii}];
        to_load=[to_load sprintf('%s ',files_csv{idx_incomp})];
    end
end
if ~isempty(diff)
    warning('Layer seem to contains more than one transect... You should double check that they have been splitted properly...');
    fprintf('File joined: %s \n',layer.Filename{:});
    fprintf('Transects contained : %s \n', diff);
end

fprintf('\n');
if ~isempty(incomplete)
    warning('Layer seem to be incomplete transects... You should load the other files as well...');
    fprintf('File loaded %s \n',layer.Filename{:});
    fprintf('Incomplete Transects: %s \n',incomplete);
    fprintf('File to load %s \n',to_load);
end

if ~isempty(idx_files)
    layer.SurveyData=survey_vec(idx_files(1));
end
fprintf('\n');


end