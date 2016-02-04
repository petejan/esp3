function map_survey_mat_callback(~,~,hObject_main)
layer=getappdata(hObject_main,'Layer');
if ~isempty(layer)
    if isvalid(layer)
        if ~isempty(layer)
            if ~isempty(layer.PathToFile)
                path=layer.PathToFile;
            else
                path=pwd;
            end
            
        else
            path=pwd;
        end
    else
        path=pwd;
    end
else
    path=pwd;
end

[Filename,PathToFile]= uigetfile( {fullfile(path,'*_survey_output.mat')}, 'Pick a survey output file','MultiSelect','on');
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