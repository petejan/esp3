function import_survey_data_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');

if ~isempty(layers)
    if ~isempty(layers(1).PathToFile)
        path=layers(1).PathToFile;
    else
        path=pwd;
    end
    
else
    return;
end

[Filename,PathToFile]= uigetfile({fullfile(path,'*.csv')}, 'Pick a Csv file','MultiSelect','off');
if Filename==0
    return;
end

[files_csv,survey_vec]=import_survey_data(PathToFile,Filename);
str_data_csv=cell(1,length(survey_vec));
for iiu=1:length(survey_vec)
   str_data_csv= survey_vec(iiu).print_survey_data();
end

for i=1:length(layers)
    files_layers=layers(i).Filename;
    idx_files=[];
    for u=1:length(files_layers)
        idx_files=union(idx_files,find(strcmpi(files_layers{u},files_csv)));
    end
    str_data=cell(1,length(idx_files));
    diff=[];
    incomplete=[];
    for ii=1:length(idx_files)
        str_data{ii}=survey_vec(idx_files(ii)).print_survey_data();
        if ~strcmpi(str_data{1},str_data{ii})
            diff=[diff '\n' str_data{ii}];
        end
        if ~((length(idx_files)==nansum(strcmpi(str_data{ii},str_data_csv))));
            incomplete=[incomplete '\n' str_data{ii}];
        end
    end
    if ~isempty(diff)
        warning('Layer seem to contains more than one transect... You should double check that they have been splitted properly...');
        fprintf('%s ',layers(i).Filename{:});
        fprintf(diff);
    end
    
    fprintf('\n');
    if ~isempty(incomplete)
        warning('Layer seem to contains incomplete transects... You should double check that they are all there...');
        fprintf('%s ',layers(i).Filename{:});
        fprintf(incomplete);
    end
    
    if ~isempty(idx_files)
        layers(i).SurveyData=survey_vec(idx_files(1));
    end 
    fprintf('\n');
end

setappdata(main_figure,'Layers',layers);
load_cursor_tool(main_figure);
update_display(main_figure,0)
end
