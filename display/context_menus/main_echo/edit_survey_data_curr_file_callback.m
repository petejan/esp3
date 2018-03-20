function edit_survey_data_curr_file_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
trans=trans_obj;

ax_main=axes_panel_comp.main_axes;
x_lim=double(get(ax_main,'xlim'));

cp = ax_main.CurrentPoint;
x=cp(1,1);


x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));


xdata=trans.get_transceiver_pings();

[~,idx_ping]=nanmin(abs(xdata-x));

ifi=find(trans.Data.FileId(idx_ping)==trans.Data.FileId);

start_time=trans.Time(ifi(1));
end_time=trans.Time(ifi(end));

if isempty(layer.SurveyData)
    surv=survey_data_cl();
else
    surv=layer.get_survey_data('Idx',1);
end

surv.StartTime=start_time;
surv.EndTime=end_time;


 surv=edit_survey_data_fig(main_figure,surv,{'off' 'off' 'on' 'on' 'on' 'on' 'on'},'Transect');
if isempty(surv)>0
    return;
end
surv.StartTime=start_time;
surv.EndTime=end_time;
layer_cl.empty.update_echo_logbook_dbfile('Filename',layer.Filename{trans.Data.FileId(idx_ping)},'SurveyData',surv);
layer.load_echo_logbook_db();
setappdata(main_figure,'Layer',layer);
import_survey_data_callback([],[],main_figure);

load_logbook_tab_from_db(main_figure,1);


end