function plot_survey_results_callback(~,~,hObject_main)
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

[Filename,PathToFile]= uigetfile( {fullfile(path_f,'*_survey_output.mat')}, 'Pick some survey output files','MultiSelect','on');
if ~isequal(Filename, 0)
    if ~iscell(Filename)
        Filename={Filename};
    end
    
    obj_vec=[];
    for i=1:length(Filename)
        load(fullfile(PathToFile,Filename{i}));
        obj_vec=[surv_obj obj_vec];
    end
    
    
    hfig=figure('Name','Time Series of results','NumberTitle','off','tag','time_series');
    if ~isempty(obj_vec)
        plot_survey_results(hfig,obj_vec);
    else
        return;
    end

    hfigs=getappdata(hObject_main,'ExternalFigures');
    hfigs_new=[hfigs hfig];
    setappdata(hObject_main,'ExternalFigures',hfigs_new);
else
    return;
end

end