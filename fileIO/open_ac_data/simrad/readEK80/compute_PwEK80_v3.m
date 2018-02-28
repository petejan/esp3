function [y,power]=compute_PwEK80_v3(Rwt_rx,Ztrd,datatype,data)


    if datatype(1)==dec2bin(0)      
        nb_chan=sum(contains(fieldnames(data),'comp_sig'));
        
        if nb_chan>0
            y=zeros(size(data.comp_sig_1));
        end
            
        for i=1:nb_chan
            y=y+data.(sprintf('comp_sig_%1d',i));
        end
        
        y=y/nb_chan;
        
        power=(nb_chan*(abs(y)/(2*sqrt(2))).^2*((Rwt_rx+Ztrd)/Rwt_rx)^2/Ztrd);
    end 

end