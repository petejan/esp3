function edit_survey_data_curr_file_callback(~,~,main_figure)
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


xdata=trans.Data.get_numbers();

[~,idx_ping]=nanmin(abs(xdata-x));

ifi=find(trans.Data.FileId(idx_ping)==trans.Data.FileId);

start_time=trans.Data.Time(ifi(1));
end_time=trans.Data.Time(ifi(end));

if isempty(layer.SurveyData)
    surv=survey_data_cl();
else
    surv=layer.get_survey_data('Idx',1);
end

surv.StartTime=start_time;
surv.EndTime=end_time;
[surv.Voyage,surv.SurveyName,surv.Snapshot,surv.Stratum,surv.Transect,cancel]=fill_survey_data_dlbox(surv,'title','Enter New Survey Data');

if cancel>0
    return;
end

layer_cl.empty.update_echo_logbook_dbfile('Filename',layer.Filename{trans.Data.FileId(idx_ping)},'SurveyData',surv);
layer.load_echo_logbook_db();
setappdata(main_figure,'Layer',layer);
import_survey_data_callback([],[],main_figure);

load_survey_data_fig_from_db(main_figure,1);



end