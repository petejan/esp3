function set_ST(trans_obj,ST)

if ~isempty(ST)
    Sp=trans_obj.Data.get_datamat('Sp');
    dataMat=nan(size(Sp));
    np=ceil(nanmean(ST.Transmitted_pulse_length));
    nb_samples=length(Sp(:));
    
    for i=-np:np
        idx=ST.idx_target_lin+i;
        idx_nope=idx<=0|idx>nb_samples;
        dataMat(idx(~idx_nope))=ST.TS_comp(~idx_nope);
    end
    
    trans_obj.Data.add_sub_data('singletarget',dataMat);
    trans_obj.ST=ST;
end

end