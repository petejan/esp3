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

        choice_str={'SliceAbscf','Nb_ST','Nb_Tracks'};
        [s,v] = listdlg('PromptString','What do you want to plot?',...
                'SelectionMode','single',...
                'ListString',choice_str,'ListSize',[150 150]);
            if v>0
                field=choice_str{s};
            end
        
        load_map_fig(hObject_main,obj_vec,'field',field);
    else
        return;
    end
else
    return;
end

end