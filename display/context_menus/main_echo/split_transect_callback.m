function split_transect_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
axes_panel_comp=getappdata(main_figure,'Axes_panel');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
trans=trans_obj;

ax_main=axes_panel_comp.main_axes;


x_lim=double(get(ax_main,'xlim'));

cp = ax_main.CurrentPoint;
x=cp(1,1);
% y=cp(1,2);

x=nanmax(x,x_lim(1));
x=nanmin(x,x_lim(2));

% y=nanmax(y,y_lim(1));
% y=nanmin(y,y_lim(2));

xdata=trans.get_transceiver_pings();


[~,idx_ping]=nanmin(abs(xdata-x));

t_n=trans.Time(idx_ping);

[surv_to_split,idx_split]=layer.get_survdata_at_time(t_n);

surv=cell(1,2);
surv{1}=survey_data_cl();
surv{2}=survey_data_cl();

if idx_split>0
    fprintf('Splitting %s at %s\n',surv_to_split.print_survey_data(),datestr(t_n));
else
    fprintf('Splitting Transect %s ===at %s\n',datestr(t_n));
end


surv{1}=edit_survey_data_fig(main_figure,surv_to_split,{'off' 'off' 'on' 'on' 'on' 'on' 'on'},'First Part');
if isempty(surv{1})
    return;
end
surv{1}.StartTime=surv_to_split.StartTime;
surv{1}.EndTime=t_n;

surv{2}=edit_survey_data_fig(main_figure,surv_to_split,{'off' 'off' 'on' 'on' 'on' 'on' 'on'},'Second Part');
if isempty(surv{2})
    return;
end

surv{2}.StartTime=t_n;
surv{2}.EndTime=surv_to_split.EndTime;

new_surveydata=layer.SurveyData;

if idx_split>0
    new_surveydata(idx_split)=[];
end

new_surveydata{length(layer.SurveyData)+1}=surv{1};
new_surveydata{length(layer.SurveyData)+2}=surv{2};
new_surveydata(cellfun(@isempty,new_surveydata))=[];

layer.set_survey_data(new_surveydata);

layer.update_echo_logbook_dbfile();

setappdata(main_figure,'Layer',layer);
update_tree_layer_tab(main_figure);
display_survdata_lines(main_figure);
update_mini_ax(main_figure,0);


load_logbook_tab_from_db(main_figure,1);

end