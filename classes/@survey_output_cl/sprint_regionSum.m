function str=sprint_regionSum(surv_out_obj)

regionSum=surv_out_obj.regionSum;
str=sprintf('\n# Region Summary\n#snapshot stratum transect file region_id ref slice_length good_pings start_d mean_d finish_d av_speed vbscf abscf\n');
prec={'%0.f,' '%s,' '%0.f,' '%s,' '%0.f,' '%s,' '%0.f,' '%0.f,' '%0.3f,' '%0.3f,' '%0.3f,' '%0.5f,' '%.5e,' '%.5e\n'};
fields=fieldnames(regionSum);
for k = 1:length(regionSum.snapshot)
    for iu=1:length(fields)-2
        switch fields{iu}
            case 'file'
                for ifs=1:length(regionSum.(fields{iu}){k})
                    [~,file,~]=fileparts(regionSum.(fields{iu}){k}{ifs});
                    if ifs>1
                        str=[str ';' file];
                    else
                        str=[str file];
                    end
                end
                
            otherwise
                
                if iscell(regionSum.(fields{iu}))
                    if ~iscell(regionSum.(fields{iu}){k})
                        str=[str sprintf(prec{iu}, regionSum.(fields{iu}){k})];
                    else
                        str=[str sprintf(prec{iu}, cell2mat(regionSum.(fields{iu}){k}))];
                    end
                else
                    str=[str sprintf(prec{iu}, regionSum.(fields{iu})(k))];
                end
        end
    end
    
end