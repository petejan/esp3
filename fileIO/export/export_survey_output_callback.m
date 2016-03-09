function export_survey_output_callback(~,~,hObject_main)
layer=getappdata(hObject_main,'Layer');

if ~isempty(layer)
    if ~isempty(layer(1).Filename)
        [path_f,~,~]=fileparts(layer.Filename{1});
    else
        path_f=pwd;
    end
    
else
    path_f=pwd;
end

[Filename,PathToFile]= uigetfile( {fullfile(path_f,'*_survey_output.mat')}, 'Pick a survey output file','MultiSelect','on');
if ~isequal(Filename, 0)
    if ~iscell(Filename)
        Filename={Filename};
    end
    
    for i=1:length(Filename)
        file_i=fullfile(PathToFile,Filename{i});
        if exist(file_i,'file')>0
            
            [path_i,file_i_n,~]=fileparts(file_i);
            load(file_i);
            surv_obj.surv_results_to_csv(fullfile(path_i,file_i_n));
        end
    end
else
    return;
end

end