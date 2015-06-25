function [T,Np]=get_pulse_Comp_length(Trans_obj)


Np=round(Trans_obj.Params.PulseLength(1)/Trans_obj.Params.SampleInterval(1));
T=Np*(Trans_obj.Params.SampleInterval(1));

switch Trans_obj.Mode
    case 'FM'
        [simu_pulse,~]=generate_sim_pulse(Trans_obj.Params,Trans_obj.Filters(1),Trans_obj.Filters(2));
        y_tx_auto=xcorr(simu_pulse)/nansum(abs(simu_pulse).^2);
        T=nansum(abs(y_tx_auto).^2)/(nanmax(abs(y_tx_auto).^2))*(Trans_obj.Params.SampleInterval(1));
        Np=round(T/Trans_obj.Params.SampleInterval(1));
    case 'CW'
        Np=round(Trans_obj.Params.PulseLength(1)/Trans_obj.Params.SampleInterval(1));
        T=Np*(Trans_obj.Params.SampleInterval(1));
end

end