function [sim_pulse,y_tx_matched]=get_pulse(trans_obj)

switch trans_obj.Config.TransceiverType
    case list_GPTs()
        sim_pulse=ones(1,4);
        y_tx_matched=flipud(conj(sim_pulse));
    case list_WBTs()
        [sim_pulse,y_tx_matched]=generate_sim_pulse(trans_obj.Params,trans_obj.Filters(1),trans_obj.Filters(2));
    otherwise
        T=trans_obj.Params.PulseLength(1);
        sim_pulse=ones(size(0:trans_obj.Params.SampleInterval(1):T));
        y_tx_matched=flipud(conj(sim_pulse));
end

end