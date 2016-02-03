function set_ST(trans_obj,ST)

if ~isempty(ST)
    Sp=trans_obj.Data.get_datamat('Sp');
    dataMat=nan(size(Sp));
    dataMat(ST.idx_target_lin)=ST.TS_comp;  
    memapname=trans_obj.Data.MemapName;   
    trans_obj.Data.remove_sub_data('singletarget');
    sub_ac_data_temp=sub_ac_data_cl('singletarget',memapname,dataMat);
    trans_obj.Data.add_sub_data(sub_ac_data_temp);
    trans_obj.ST=ST;
end

end