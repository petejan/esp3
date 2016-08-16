function data=compute_PwEK80_v2(trans_obj,data)

Rwt_rx=1e3;%ohms
Ztrd=75;%ohms

for idx_freq=1:length(trans_obj)

    switch trans_obj(idx_freq).Config.TransceiverType
        case {'WBT','WBT Tube'}
            
            
            FreqStart=(trans_obj(idx_freq).Params.FrequencyStart(1));
            FreqEnd=(trans_obj(idx_freq).Params.FrequencyEnd(1));
            FreqCenter=(FreqStart+FreqEnd)/2;
            
            
            s1=data.pings(idx_freq).comp_sig_1;
            s2=data.pings(idx_freq).comp_sig_2;
            s3=data.pings(idx_freq).comp_sig_3;
            s4=data.pings(idx_freq).comp_sig_4;
            
            data.pings(idx_freq).y=(s1+s2+s3+s4)/4;
            
            y=data.pings(idx_freq).y;
            data.pings(idx_freq).power=4*(abs(y)/(2*sqrt(2))).^2*((Rwt_rx+Ztrd)/Rwt_rx)^2/Ztrd;
            
        case 'GPT'
            FreqCenter=trans_obj(idx_freq).Params.FrequencyEnd(1);
 
    end
    
end
end