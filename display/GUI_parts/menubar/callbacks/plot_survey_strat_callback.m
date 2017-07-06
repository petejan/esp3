function plot_survey_strat_callback(~,~,main_figure)

app_path=getappdata(main_figure,'App_path');

[Filename,PathToFile]= uigetfile( {fullfile(app_path.results,'*_survey_output.mat')}, 'Pick some survey output files','MultiSelect','on');
if ~isequal(Filename, 0)
    
    if ~iscell(Filename)
        Filename={Filename};
    end
    obj_vec=[];
    for i=1:length(Filename)
        load(fullfile(PathToFile,Filename{i}));
        obj_vec=[obj_vec surv_obj];
    end
    
    
    
    hfig=new_echo_figure(main_figure,'Name','Survey Results: Stratum','Tag','results_strat');
    
    if ~isempty(surv_obj)
        obj_vec.plot_survey_strat_result(hfig);
        for i=1:length(obj_vec)
            hfig_2(i)=new_echo_figure(main_figure,'Name',sprintf('Survey Results %s: Transect',Filename{i}),'Tag',sprintf('results_trans%s',Filename{i}));
            obj_vec(i).plot_survey_trans_result(hfig_2(i));
        end
    else
        close(hfig);
        return;
    end
    
    
else
    return;
end

end