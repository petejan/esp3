function data=compute_PwEK80_v2(trans_obj,data)

for idx_freq=1:length(trans_obj)
Rwt_rx=trans_obj(idx_freq).Config.Impedance;
Ztrd=trans_obj(idx_freq).Config.Ztrd;
    switch trans_obj(idx_freq).Config.TransceiverType
        case list_WBTs()
            
            s1=(data.pings(idx_freq).comp_sig_1);
            s2=(data.pings(idx_freq).comp_sig_2);
            s3=(data.pings(idx_freq).comp_sig_3);
            s4=(data.pings(idx_freq).comp_sig_4);
            
            nb_chan=sum(any(s1(:))+any(s2(:))+any(s3(:))+any(s4(:)));
            data.pings(idx_freq).y=zeros(size(s1));
            
            for i=1:nb_chan
                data.pings(idx_freq).y=data.pings(idx_freq).y+data.pings(idx_freq).(sprintf('comp_sig_%1d',i));
            end
            
            data.pings(idx_freq).y=gather(data.pings(idx_freq).y/nb_chan);

            data.pings(idx_freq).power=(nb_chan*(abs(data.pings(idx_freq).y)/(2*sqrt(2))).^2*((Rwt_rx+Ztrd)/Rwt_rx)^2/Ztrd);

 
    end
    
end
end