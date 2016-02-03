function str=sprint_regionSumAbscf(surv_out_obj)
regionSumAbscf=surv_out_obj.regionSumAbscf;

str=sprintf('\n# Region Summary (abscf by vertical slice)\n#snapshot stratum transect file region_id num_v_slices {transmit_start latitude longitude column_abscf}\n');

prec={'%0.f,' '%s,' '%0.f,' '%s,' '%0.f,' '%0.f,'};

fields=fieldnames(regionSumAbscf);
for k = 1:length(regionSumAbscf.snapshot)
    for iu=1:length(fields)-6
        if iscell(regionSumAbscf.(fields{iu}))
             if ~iscell(regionSumAbscf.(fields{iu}){k})
                str=[str sprintf(prec{iu}, regionSumAbscf.(fields{iu}){k})];
            else
                str=[str sprintf(prec{iu}, cell2mat(regionSumAbscf.(fields{iu}){k}))];
            end
        else
            str=[str sprintf(prec{iu}, regionSumAbscf.(fields{iu})(k))];
        end
    end
    for ik=1:length(regionSumAbscf.latitude{k})
        str=[str sprintf('%.0f,', regionSumAbscf.transmit_start{k}(ik))];
        str=[str sprintf('%.4f,', regionSumAbscf.latitude{k}(ik))];
        str=[str sprintf('%.4f,', regionSumAbscf.longitude{k}(ik))];
        if regionSumAbscf.column_abscf{k}(ik)==0||isnan(regionSumAbscf.column_abscf{k}(ik))
            precslice_abscf='%.0f,';
            str=[str sprintf(precslice_abscf, 0)];
        else
            precslice_abscf='%.5e,';
            str=[str sprintf(precslice_abscf, regionSumAbscf.column_abscf{k}(ik))];
        end
        
    end
    str=str(1:end-1);
    str=[str sprintf('\n')];
end
end
