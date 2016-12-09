function [T,Np]=get_pulse_Teff(trans_obj)

if ~isempty(trans_obj.Filters)
    [simu_pulse,~]=generate_sim_pulse(trans_obj.Params,trans_obj.Filters(1),trans_obj.Filters(2));
    y_tx_auto=xcorr(simu_pulse)/nansum(abs(simu_pulse).^2);
    T=nansum(abs(y_tx_auto).^2)/(nanmax(abs(y_tx_auto).^2))*(trans_obj.Params.SampleInterval(1));
    Np=round(T/trans_obj.Params.SampleInterval(1));
else
    [T,Np]=trans_obj.get_pulse_length();
end


end