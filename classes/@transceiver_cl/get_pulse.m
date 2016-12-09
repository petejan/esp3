function [sim_pulse,y_tx_matched]=get_pulse(trans_obj)

switch trans_obj.Config.TransceiverType
    case 'GPT'
        sim_pulse=ones(1,4);
        y_tx_matched=flipud(conj(sim_pulse))/nanmax(abs(sim_pulse));
    case {'WBT' 'WBT Tube'}
        [sim_pulse,y_tx_matched]=generate_sim_pulse(trans_obj.Params,trans_obj.Filters(1),trans_obj.Filters(2));
end

end