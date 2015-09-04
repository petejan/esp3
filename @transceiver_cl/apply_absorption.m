function apply_absorption(trans,alpha)

alpha_ori=trans.Params.Absorbtion;

Sv=trans.Data.get_datamat('sv');
Sp=trans.Data.get_datamat('sp');

if isempty(Sp)||isempty(Sv)
    warning('Could not apply new absorption, no Sv/Sp datagrams');
    return;
end

name=trans.Data.MemapName;
trans.Data.remove_sub_data('sv');
trans.Data.remove_sub_data('sp');
[Sp_new,Sv_new]=apply_new_absorption(Sp,Sv,...
    trans.Data.Range,alpha_ori,alpha);
trans.Params.Absorbtion=alpha;

trans.Data.add_sub_data(sub_ac_data_cl('sv',name,Sv_new));
trans.Data.add_sub_data(sub_ac_data_cl('sp',name,Sp_new));


end