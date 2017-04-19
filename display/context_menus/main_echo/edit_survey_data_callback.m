function edit_survey_data_callback(~,~,main_figure,rem)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
trans=layer.Transceivers(idx_freq);

ax_main=axes_panel_comp.main_axes;
x_lim=double(get(ax_main,'xlim'));

cp = ax_main.CurrentPoint;
x=cp(1,1);

x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));

xdata=trans.get_transceiver_pings();

[~,idx_ping]=nanmin(abs(xdata-x));

t_n=trans.Data.Time(idx_ping);

[surv_to_modif,idx_modif]=layer.get_survdata_at_time(t_n);

if idx_modif>0
    fprintf('Modifying Survey data for %s\n',surv_to_modif.print_survey_data());
    surv_temp=surv_to_modif;
else
    surv_temp= layer.get_survey_data('Idx',1);
    fprintf('Modifying Survey Data\n');
end


if rem==0
    surv=survey_data_cl();
    [surv.Voyage,surv.SurveyName,surv.Snapshot,surv.Stratum,surv.Transect,cancel]=fill_survey_data_dlbox(surv_temp,'title','Enter New Survey Data');
    if cancel>0
        return;
    end
else
    surv=survey_data_cl();
    surv.Voyage=surv_temp.Voyage;
    surv.SurveyName=surv_temp.SurveyName;   
end

surv.StartTime=surv_temp.StartTime;
surv.EndTime=surv_temp.EndTime;

surv_data_tot=layer.SurveyData;

if idx_modif>0
    new_surveydata=surv_data_tot;
    new_surveydata{idx_modif}=surv;
else
    new_surveydata=surv_data_tot;
    new_surveydata{length(surv_data_tot)+1}=surv;
    
end

layer.set_survey_data(new_surveydata);
layer.update_echo_logbook_dbfile();
setappdata(main_figure,'Layer',layer);

update_layer_tab(main_figure);
display_survdata_lines(main_figure)
update_mini_ax(main_figure,0);
load_survey_data_fig_from_db(main_figure,1);
