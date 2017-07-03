function hfig=plot_survey_strat_result(surv_obj,hfig)

plot_color={'k','r','g','m','y'};

strat_sum=surv_obj.SurvOutput.stratumSum;
snaps=unique(strat_sum.snapshot);
strats=unique(strat_sum.stratum);
nb_snap=numel(snaps);
nb_strat=length(snaps);

abscf_mean=nan(nb_snap,nb_strat);
abscf_std=nan(nb_snap,nb_strat);

if isempty(hfig)
    hfig=figure();
else
    figure(hfig);
end
ax=axes(hfig);
hold(ax,'on');
grid(ax,'on');
box(ax,'on')
for i=1:length(nb_snap)  
    for j=1:length(strats)
        idx=(strat_sum.snapshot==snaps(i)&strcmp(strat_sum.stratum,strats{j}));  
        abscf_mean(i,j)=strat_sum.abscf_mean(idx);
        abscf_std(i,j)=strat_sum.abscf_sd(idx);    
    end
    errorbar(ax,abscf_mean,abscf_std,'marker','s','color',plot_color{i});
end
set(ax,'xtick',1:length(strats));
set(ax,'xticklabel',strats);
ylabel(ax,'abscf')
xlabel(ax,'stratum');



end