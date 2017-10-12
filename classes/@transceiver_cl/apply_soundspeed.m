function apply_soundspeed(trans_obj,new_c)

old_range=trans_obj.get_transceiver_range();

new_range = trans_obj.compute_transceiver_range(new_c);

[~,Np]=trans_obj.get_pulse_length(1);

[TVG_Sp_old,TVG_Sv_old]=computeTVG(old_range,Np);

[TVG_Sp_new,TVG_Sv_new]=computeTVG(new_range,Np);

alpha=trans_obj.Params.Absorption(1);

alpha_diff=2*alpha*(new_range-old_range);

trans_obj.set_transceiver_range(new_range);

Sv=trans_obj.Data.get_datamat('sv');
Sp=trans_obj.Data.get_datamat('sp');
Sp_un=trans_obj.Data.get_datamat('spunmatched');

if ~isempty(Sv)
    Sv=bsxfun(@plus,Sv,TVG_Sv_new-TVG_Sv_old+alpha_diff);
    trans_obj.Data.replace_sub_data('sv',Sv);
end

if ~isempty(Sp)
    Sp=bsxfun(@plus,Sp,TVG_Sp_new-TVG_Sp_old+alpha_diff);
    trans_obj.Data.replace_sub_data('sp',Sp);
end

if ~isempty(Sp_un)
    Sp_un=bsxfun(@plus,Sp_un,TVG_Sp_new-TVG_Sp_old+alpha_diff);
    trans_obj.Data.replace_sub_data('spunmatched',Sp_un);
end

