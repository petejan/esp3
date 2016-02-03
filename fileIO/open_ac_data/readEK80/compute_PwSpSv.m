

function data=compute_PwSpSv(data)

Rwt_rx=1e3;%ohms
Ztrd=75;%ohms

for idx_freq=1:length(data.config)
    
    
    f_s_sig=round(1/(data.params(idx_freq).SampleInterval(1)));
    c=(data.env.SoundSpeed);
    FreqStart=(data.params(idx_freq).FrequencyStart(1));
    FreqEnd=(data.params(idx_freq).FrequencyEnd(1));
    Freq=(data.config(idx_freq).Frequency);
    ptx=(data.params(idx_freq).TransmitPower(1));
    pulse_length=(data.params(idx_freq).PulseLength(1));
    gains=data.config(idx_freq).Gain;
    pulse_lengths=data.config(idx_freq).PulseLength;
    eq_beam_angle=data.config(idx_freq).EquivalentBeamAngle;
    FreqCenter=(FreqStart+FreqEnd)/2;
    lambda=c/FreqCenter;
    eq_beam_angle_curr=eq_beam_angle+20*log10(Freq/(FreqCenter));
    
    
    [~,idx_pulse]=nanmin(abs(pulse_lengths-pulse_length));
    gain=gains(idx_pulse);
    
    s1=data.pings(idx_freq).comp_sig_1;
    s2=data.pings(idx_freq).comp_sig_2;
    s3=data.pings(idx_freq).comp_sig_3;
    s4=data.pings(idx_freq).comp_sig_4;
    
    data.pings(idx_freq).y=(s1+s2+s3+s4)/4;
    
    [nb_samples,nb_pings]=size(data.pings(idx_freq).y);
    data.pings(idx_freq).ping_num=(1:nb_pings);
    time=1/f_s_sig*(0:nb_samples-1)';
    range=c*time/2;
       
    
    alpha= sw_absorption(FreqCenter/1e3, (data.env.Salinity), (data.env.Temperature), (data.env.Depth),'fandg')/1e3;
    
    data.params(idx_freq).Absorbtion=alpha;
    data.pings(idx_freq).range=range;

    y=data.pings(idx_freq).y;
    data.pings(idx_freq).power=4*(abs(y)/(2*sqrt(2))).^2*((Rwt_rx+Ztrd)/Rwt_rx)^2/Ztrd;
    

    if isfield(data.pings(idx_freq),'simu_pulse')
        pulse_auto_corr=xcorr(data.pings(idx_freq).simu_pulse)/nansum(abs(data.pings(idx_freq).simu_pulse).^2);
        t_eff=nansum(abs(pulse_auto_corr).^2)/(nanmax(abs(pulse_auto_corr).^2)*f_s_sig);
    else
        t_eff=pulse_length;
    end
    
    sacorr=0;
    
    [data.pings(idx_freq).Sp,data.pings(idx_freq).Sv]=...
        convert_power(data.pings(idx_freq).power,range,c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle_curr,sacorr);
    

end

end