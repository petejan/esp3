function hfig=plot_survey_strat_result(surv_obj,hfig)

plot_color={'k','r',[0 0.8 0],'b',[0.8 0.8 0],'m'};
if isempty(hfig)
    hfig=figure();
else
    figure(hfig);
end

ax=axes(hfig);
hold(ax,'on');
grid(ax,'on');
box(ax,'on')

snaps=[];
strats=[];
legend_name=cell(1,length(surv_obj));
for isur=1:length(surv_obj)
    strat_sum=surv_obj(isur).SurvOutput.stratumSum;
    snaps=unique(strat_sum.snapshot);
    strats=unique(strat_sum.stratum);
    legend_name{isur}=surv_obj(isur).SurvInput.Infos.Title;
end
% 
% [~,idx_strats_reorder]=sort((str2double(strats)));
% strats=strats(idx_strats_reorder);
% 
% strats(strcmpi(strats,'E'))=[];

nb_snap=numel(snaps);
nb_strat=length(snaps);
nb_surv=length(surv_obj);

abscf_mean=nan(nb_snap,nb_strat,nb_surv);
abscf_std=nan(nb_snap,nb_strat,nb_surv);
icol=0;
for isur=1:length(surv_obj)
    strat_sum=surv_obj(isur).SurvOutput.stratumSum;
    for i=1:length(nb_snap)
        icol=icol+1;
        for j=1:length(strats)
            idx=(strat_sum.snapshot==snaps(i)&strcmp(strat_sum.stratum,strats{j}));
            if any(idx)
            abscf_mean(i,j,isur)=strat_sum.abscf_wmean(idx);
            abscf_std(i,j,isur)=sqrt(strat_sum.abscf_var(idx));
            end
        end
        
    errorbar(ax,abscf_mean(i,:,isur),abscf_std(i,:,isur),'marker','s','color',plot_color{icol});
    end

    
end

set(ax,'xtick',1:length(strats));
set(ax,'xticklabel',strats);
ylabel(ax,'s_a(m^2m^{-2})')
xlabel(ax,'Stratum Name');
legend(ax,legend_name,'interpreter','none')

end