function map_survey_mat_callback(~,~,hObject_main)

app_path=getappdata(hObject_main,'App_path');

[Filename,PathToFile]= uigetfile( {fullfile(app_path.results,'*_survey_output.mat')}, 'Pick a survey output file','MultiSelect','on');
if ~isequal(Filename, 0)
    if ~iscell(Filename)
        Filename={Filename};
    end
    
    obj_vec=[];
    for i=1:length(Filename)
        load(fullfile(PathToFile,Filename{i}));
        obj_vec=[surv_obj obj_vec];
    end
    
    if ~isempty(obj_vec)

        load_map_fig(hObject_main,obj_vec);
    else
        return;
    end
else
    return;
end

end