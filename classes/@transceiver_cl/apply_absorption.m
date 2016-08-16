function apply_absorption(trans,alpha)

alpha_ori=trans.Params.Absorption(1);

if alpha_ori==alpha
    return;
end

Sv=trans.Data.get_datamat('sv');

if ~isempty(Sv)
    Sv_new=apply_new_absorption(Sv,trans.Data.get_range(),alpha_ori,alpha);
    trans.Params.Absorption=alpha;
    trans.Data.add_sub_data('sv',Sv_new);
end

Sp=trans.Data.get_datamat('sp');

if ~isempty(Sp)
    Sp_new=apply_new_absorption(Sp,trans.Data.get_range(),alpha_ori,alpha);
    trans.Params.Absorption=alpha;
    trans.Data.add_sub_data('sp',Sp_new);
end


end