function apply_absorption(trans,alpha)

alpha_ori=trans.Params.Absorbtion;

Sv=trans.Data.get_datamat('sv');
Sp=trans.Data.get_datamat('sp');

name=trans.Data.MemapName;


if ~isempty(Sv)
    Sv_new=apply_new_absorption(Sv,...
        trans.Data.Range,alpha_ori,alpha);
    trans.Params.Absorbtion=alpha;
    trans.Data.remove_sub_data('sv');
    trans.Data.add_sub_data(sub_ac_data_cl('sv',name,Sv_new));
end

if ~isempty(Sp)
    Sp_new=apply_new_absorption(Sp,...
        trans.Data.Range,alpha_ori,alpha);
    trans.Params.Absorbtion=alpha;
    trans.Data.remove_sub_data('sp');
    trans.Data.add_sub_data(sub_ac_data_cl('sp',name,Sp_new));
end





end