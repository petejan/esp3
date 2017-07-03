function plot_survey_strat_callback(~,~,main_figure)

app_path=getappdata(main_figure,'App_path');

[Filename,PathToFile]= uigetfile( {fullfile(app_path.results,'*_survey_output.mat')}, 'Pick some survey output files','MultiSelect','off');
if ~isequal(Filename, 0)

   
    load(fullfile(PathToFile,Filename));
    

    hfig=new_echo_figure(main_figure,'Name','Survey Results: Stratum','Tag','results_strat');
    hfig2=new_echo_figure(main_figure,'Name','Survey Results: Transect','Tag','results_trans');
    if ~isempty(surv_obj)
        surv_obj.plot_survey_strat_result(hfig);
        surv_obj.plot_survey_trans_result(hfig2);
    else
        close(hfig);
        return;
    end
    
    
else
    return;
end

end