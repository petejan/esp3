function apply_absorption(trans,alpha)
    
    alpha_ori=trans.Params.Absorbtion;
    
    [idx_sp,found_sp]=find_type_idx(trans.Data,'Sp');
    [idx_sv,found_sv]=find_type_idx(trans.Data,'Sv');
    
    if found_sp==0||found_sv==0
        warning('Could not apply new absorption, no Sv/Sp datagrams');
        return;
    end
    
    [trans.Data.SubData(idx_sp).DataMat,trans.Data.SubData(idx_sv).DataMat]=apply_new_absorption(trans.Data.SubData(idx_sp).DataMat,trans.Data.SubData(idx_sv).DataMat,...
        trans.Data.Range,alpha_ori,alpha);
    trans.Params.Absorbtion=alpha;

end