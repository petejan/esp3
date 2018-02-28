function apply_soundspeed(trans_obj,new_c)

old_range=trans_obj.get_transceiver_range();

new_range = trans_obj.compute_transceiver_range(new_c);


[~,Np]=trans_obj.get_pulse_length(1);

[TVG_Sp_old,TVG_Sv_old]=computeTVG(old_range,Np);

[TVG_Sp_new,TVG_Sv_new]=computeTVG(new_range,Np);

alpha=trans_obj.Params.Absorption(1);

alpha_diff=2*alpha*(new_range-old_range);

trans_obj.set_transceiver_range(new_range);


diff_db_sv=TVG_Sv_new-TVG_Sv_old+alpha_diff;

diff_db_sp=TVG_Sp_new-TVG_Sp_old+alpha_diff;

trans_obj.Data.add_to_sub_data('sv',diff_db_sv);
trans_obj.Data.add_to_sub_data('sp',diff_db_sp);
trans_obj.Data.add_to_sub_data('spunmatched',diff_db_sp);

