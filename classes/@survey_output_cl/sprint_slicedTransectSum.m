function str=sprint_slicedTransectSum(surv_out_obj)
slicedTransectSum=surv_out_obj.slicedTransectSum;

str=sprintf('\n# Sliced Transect Summary\n#snapshot stratum transect slice_length num_slices {latitude longitude slice_abscf}\n');

prec={'%0.f,' '%s,' '%0.f,' '%0.f,' '%0.f,'};
fields=fieldnames(slicedTransectSum);
for k = 1:length(slicedTransectSum.snapshot)
    for iu=1:length(prec)
        if iscell(slicedTransectSum.(fields{iu}))
            str=[str sprintf(prec{iu}, slicedTransectSum.(fields{iu}){k})];
        else
            str=[str sprintf(prec{iu}, slicedTransectSum.(fields{iu})(k))];
        end
    end
    
    for ik=1:length(slicedTransectSum.latitude{k})
        str=[str sprintf('%.4f,', slicedTransectSum.latitude{k}(ik))];
        str=[str sprintf('%.4f,', slicedTransectSum.longitude{k}(ik))];
        if slicedTransectSum.slice_abscf{k}(ik)==0||isnan(slicedTransectSum.slice_abscf{k}(ik))
            precslice_abscf='%.0f,';
            str=[str sprintf(precslice_abscf, 0)];
        else
            precslice_abscf='%.5e,';
            str=[str sprintf(precslice_abscf, slicedTransectSum.slice_abscf{k}(ik))];
    end
        end
        
    str=str(1:end-1);
    str=[str sprintf('\n')];
end
end
