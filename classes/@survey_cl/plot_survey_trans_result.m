function hfig=plot_survey_trans_result(surv_obj,hfig)

% plot_color={'k','r','g','m','y'};

trans_sum=surv_obj.SurvOutput.transectSum;

label=cell(1,length(trans_sum));
for j = 1:length(trans_sum.snapshot)
    label{j}=sprintf('S:%d St: %s T: %d ',trans_sum.snapshot(j),trans_sum.stratum{j},trans_sum.transect(j));
end


if isempty(hfig)
    hfig=figure();
else
    figure(hfig);
end

ax=axes(hfig);
hold(ax,'on');
grid(ax,'on');
box(ax,'on')
plot(ax,trans_sum.abscf,'marker','s','color','k');
set(ax,'xtick',1:length(trans_sum.abscf));
set(ax,'xticklabel',label);
ax.XTickLabelRotation=90;
ylabel(ax,'abscf')

