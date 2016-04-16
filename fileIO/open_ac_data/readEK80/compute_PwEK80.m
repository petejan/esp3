

function data=compute_PwEK80(data)


Rwt_rx=1e3;%ohms
Ztrd=75;%ohms

for idx_freq=1:length(data.config)
    f_s_sig=round(1/(data.params(idx_freq).SampleInterval(1)));
    c=(data.env.SoundSpeed);
    switch data.config(idx_freq).TransceiverType
        case 'WBT'
            
            
            FreqStart=(data.params(idx_freq).FrequencyStart(1));
            FreqEnd=(data.params(idx_freq).FrequencyEnd(1));
            FreqCenter=(FreqStart+FreqEnd)/2;
            
            
            s1=data.pings(idx_freq).comp_sig_1;
            s2=data.pings(idx_freq).comp_sig_2;
            s3=data.pings(idx_freq).comp_sig_3;
            s4=data.pings(idx_freq).comp_sig_4;
            
            data.pings(idx_freq).y=(s1+s2+s3+s4)/4;
            
            y=data.pings(idx_freq).y;
            data.pings(idx_freq).power=4*(abs(y)/(2*sqrt(2))).^2*((Rwt_rx+Ztrd)/Rwt_rx)^2/Ztrd;
            
        case 'GPT'
            FreqCenter=data.params(idx_freq).FrequencyEnd(1);
            
            
    end
    
    
    [nb_samples,nb_pings]=size(data.pings(idx_freq).power);
    data.pings(idx_freq).ping_num=(1:nb_pings);
    time=1/f_s_sig*(0:nb_samples-1)';
    range=c*time/2;
    
    alpha= sw_absorption(FreqCenter/1e3, (data.env.Salinity), (data.env.Temperature), (data.env.Depth),'fandg')/1e3;
    data.params(idx_freq).Absorption=alpha;
    data.pings(idx_freq).range=range;
end
end