function plot_survey_results(hfig,obj_vec)

abscf_mean=nan(1,length(obj_vec));
abscf_wmean=nan(1,length(obj_vec));
abscf_std=nan(1,length(obj_vec));
abscf_wstd=nan(1,length(obj_vec));
time=nan(1,length(obj_vec));
nb_st_per_km=nan(1,length(obj_vec));
nb_tracks_per_km=nan(1,length(obj_vec));

strat_lim=[0 50 100 150];
nb_idx=zeros(length(strat_lim)-1,length(obj_vec));
abscf_strat=zeros(length(strat_lim)-1,length(obj_vec));
strat_str=cell(1,length(strat_lim)-1);
for i_dd=1:(length(strat_lim)-1)
strat_str{i_dd}=sprintf('%d-%dm',strat_lim(i_dd),strat_lim(i_dd+1));
end


for i=1:length(obj_vec)
    abscf_mean(i)=obj_vec(i).SurvOutput.stratumSum.abscf_mean;
    abscf_wmean(i)=obj_vec(i).SurvOutput.stratumSum.abscf_wmean;
    abscf_std(i)=obj_vec(i).SurvOutput.stratumSum.abscf_sd;
    abscf_wstd(i)=sqrt(obj_vec(i).SurvOutput.stratumSum.abscf_var);
    time(i)=(obj_vec(i).SurvOutput.stratumSum.time_start+obj_vec(i).SurvOutput.stratumSum.time_end)/2;
    
    nb_trans=length(obj_vec(i).SurvOutput.transectSum.dist);
    nb_st_per_km(i)=nanmean(obj_vec(i).SurvOutput.transectSumTracks.nb_st(1:nb_trans)./obj_vec(i).SurvOutput.transectSum.dist);
    nb_tracks_per_km(i)=nanmean(obj_vec(i).SurvOutput.transectSumTracks.nb_tracks(1:nb_trans)./obj_vec(i).SurvOutput.transectSum.dist);
    
    for i_reg=1:length(obj_vec(i).SurvOutput.regionsIntegrated.snapshot)
        out=obj_vec(i).SurvOutput.regionsIntegrated.RegOutput{i_reg};
        if ~isempty(out)
            depth=out.Layer_depth_min;
            nb_idx(:,i)=nb_idx(:,i)+nansum(nanmax(out.Nb_good_pings_esp2));
            for i_d=1:(length(strat_lim)-1)
                idx_depth=depth>=strat_lim(i_d)&depth<strat_lim(i_d+1);
                if ~isempty(idx_depth)
                    abscf_strat(i_d,i)=nansum([abscf_strat(i_d,i) nansum(out.Sa_lin(idx_depth))]);
                end
            end
        end
    end
end
nb_idx(nb_idx==0)=nan;
abscf_strat=abscf_strat./nb_idx;

[time_s,idx_sort]=sort(time);

figure(hfig);
ax=subplot(2,1,1);
errorbar(time_s,abscf_wmean(idx_sort),abscf_wstd(idx_sort),'marker','s','color','k');
hold on;grid on;
errorbar(time_s,abscf_mean(idx_sort),abscf_std(idx_sort),'marker','d');
plot(time_s,nansum(abscf_strat(:,idx_sort)),'marker','d');
set(ax,'xtick',time_s);
set(ax,'xticklabel',datestr(time_s,'mmm yy'));
title('abscf_{mean}')
legend('Weighted','Non-Weighted')

ax2=subplot(2,1,2);
plot(time_s,abscf_strat(:,idx_sort),'marker','d');
hold on;grid on;
set(ax2,'xtick',time_s);
set(ax2,'xticklabel',datestr(time_s,'mmm yy'));
%set(ax2,'ylim',get(ax,'ylim'));
title('abscf_{mean} per depth slice')
legend(strat_str)


figure();
ax=subplot(2,1,1);

hold on;grid on;
plot(time_s,nb_tracks_per_km(idx_sort),'marker','d');
set(ax,'xtick',time_s);
set(ax,'xticklabel',datestr(time_s,'mmm yy'));
title('Nb Tracks/km');


ax2=subplot(2,1,2);
plot(time_s,nb_st_per_km(idx_sort),'marker','d');
hold on;grid on;
set(ax2,'xtick',time_s);
set(ax2,'xticklabel',datestr(time_s,'mmm yy'));
title('Nb ST/km');



end