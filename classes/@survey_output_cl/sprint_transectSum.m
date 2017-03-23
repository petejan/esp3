function str=sprint_transectSum(surv_out_obj)
transectSum=surv_out_obj.transectSum;

str=sprintf('\n# Transect Summary\n#snapshot stratum transect dist vbscf abscf mean_d pings av_speed start_lat start_lon finish_lat finish_lon\n');
prec={'%0.f,' '%s,' '%0.f,' '%0.4f,' '%.5e,' '%.5e,' '%0.3f,' '%0.f,' '%0.5f,' '%0.4f,' '%0.4f,' '%0.4f,' '%0.4f'};
fields=fieldnames(transectSum);
for k = 1:length(transectSum.snapshot)
    for iu=1:length(prec)
        if iscell(transectSum.(fields{iu}))
            str=[str sprintf(prec{iu}, transectSum.(fields{iu}){k})];
        else
           str=[str sprintf(prec{iu}, transectSum.(fields{iu})(k))];
        end
    end
    str=[str sprintf('\n')];
end