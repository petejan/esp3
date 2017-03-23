function str=sprint_stratumSum(surv_out_obj)

stratumSum=surv_out_obj.stratumSum;
str=sprintf('\n# Stratum Summary\n#snapshot stratum no_transects abscf_mean abscf_sd abscf_wmean abscf_var\n');
prec={'%0.f,' '%s,' '%0.f,' '%.5e,' '%.5e,' '%.5e,' '%.5e'};
fields=fieldnames(stratumSum);
for k = 1:length(stratumSum.snapshot)
    for iu=1:length(prec)
        if iscell(stratumSum.(fields{iu}))
            str=[str sprintf(prec{iu}, stratumSum.(fields{iu}){k})];
        else
            str=[str sprintf(prec{iu}, stratumSum.(fields{iu})(k))];
        end
    end
    str=[str sprintf('\n')];
end