function apply_absorption(trans,alpha)

alpha_ori=trans.Params.Absorption(1);

if alpha_ori==alpha
    return;
end


[~,Np]=trans.get_pulse_length(1);

fprintf('   Old Absorption value: %.1f dB/km\n',alpha_ori*1e3);
fprintf('   New Absorption value: %.1f dB/km\n',alpha*1e3);
diff_db=compute_abs_diff(trans.get_transceiver_range(),alpha_ori,alpha,Np);
trans.Params.Absorption=alpha*ones(1,length(trans.Params.Absorption));

trans.Data.add_to_sub_data('sv',diff_db);
trans.Data.add_to_sub_data('sp',diff_db);



end