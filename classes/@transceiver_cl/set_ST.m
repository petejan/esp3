function set_ST(trans_obj,ST)

if ~isempty(ST)
    Sp=trans_obj.Data.get_datamat('Sp');
    dataMat=nan(size(Sp));
    dataMat(ST.idx_target_lin)=ST.TS_comp;  

    trans_obj.Data.add_sub_data('singletarget',dataMat);
    trans_obj.ST=ST;
end

end