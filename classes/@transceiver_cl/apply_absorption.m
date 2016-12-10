function apply_absorption(trans,alpha)

alpha_ori=trans.Params.Absorption(1);

if alpha_ori==alpha
    return;
end

Sv=trans.Data.get_datamat('sv');
[~,Np]=trans.get_pulse_length();
if ~isempty(Sv)
    Sv_new=apply_new_absorption(Sv,trans.Data.get_range(),alpha_ori,alpha,Np);
    trans.Params.Absorption=alpha*ones(1,length(trans.Params.Absorption));
    trans.Data.replace_sub_data('sv',Sv_new);
end

Sp=trans.Data.get_datamat('sp');

if ~isempty(Sp)
    Sp_new=apply_new_absorption(Sp,trans.Data.get_range(),alpha_ori,alpha,Np);
    trans.Params.Absorption=alpha*ones(1,length(trans.Params.Absorption));
    trans.Data.replace_sub_data('sp',Sp_new);
end


end