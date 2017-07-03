function plot_survey_results_callback(~,~,main_figure)
app_path=getappdata(main_figure,'App_path');


[Filename,PathToFile]= uigetfile( {fullfile(app_path.results,'*_survey_output.mat')}, 'Pick some survey output files','MultiSelect','on');
if ~isequal(Filename, 0)
    if ~iscell(Filename)
        Filename={Filename};
    end
    
    obj_vec=[];
    for i=1:length(Filename)
        load(fullfile(PathToFile,Filename{i}));
        obj_vec=[surv_obj obj_vec];
    end
    
    
    hfig=new_echo_figure(main_figure,'Name','Time Series of results','Tag','time_series');
    if ~isempty(obj_vec)
        plot_survey_results(hfig,obj_vec);
    else
        close(hfig);
        return;
    end


else
    return;
end

end