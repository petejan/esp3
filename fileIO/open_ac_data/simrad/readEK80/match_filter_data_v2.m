function [data_c,mode]=match_filter_data_v2(trans_obj,data)

mode=cell(1,length(trans_obj));
for idx_freq=1:length(trans_obj)
    if trans_obj(idx_freq).Params.FrequencyStart(1)~=trans_obj(idx_freq).Params.FrequencyEnd(1) 
        mode{idx_freq}='FM';
        
        [sim_pulse,y_tx_matched]=generate_sim_pulse(trans_obj(idx_freq).Params,trans_obj(idx_freq).Filters(1),trans_obj(idx_freq).Filters(2));
        
        s1=(data.pings(idx_freq).comp_sig_1);
        s2=(data.pings(idx_freq).comp_sig_2);
        s3=(data.pings(idx_freq).comp_sig_3);
        s4=(data.pings(idx_freq).comp_sig_4);
        
        [~,nb_pings]=size(s1);
        
        data.pings(idx_freq).ping_num=(1:nb_pings);
               
        data.pings(idx_freq).match_filter=(y_tx_matched);
        data.pings(idx_freq).simu_pulse=(sim_pulse);
        
        if isa(s1,'gpuArray')
            y_tx_matched=gpuArray(y_tx_matched);
        end
        
        val_sq=sum(abs(y_tx_matched).^2); 
             
  
           n = size(y_tx_matched,1) + size(s1,1) - 1; 
        yc_1_temp = ifft(bsxfun(@times,fft(y_tx_matched,n),fft(s1,n,1)),n,1)/val_sq; 
        yc_2_temp = ifft(bsxfun(@times,fft(y_tx_matched,n),fft(s2,n,1)),n,1)/val_sq; 
        yc_3_temp = ifft(bsxfun(@times,fft(y_tx_matched,n),fft(s3,n,1)),n,1)/val_sq; 
        yc_4_temp = ifft(bsxfun(@times,fft(y_tx_matched,n),fft(s4,n,1)),n,1)/val_sq; 
        
        
        nb_samples=numel(y_tx_matched);

        data.pings(idx_freq).comp_sig_1=(yc_1_temp(nb_samples:end,:));
        data.pings(idx_freq).comp_sig_2=(yc_2_temp(nb_samples:end,:));
        data.pings(idx_freq).comp_sig_3=(yc_3_temp(nb_samples:end,:));
        data.pings(idx_freq).comp_sig_4=(yc_4_temp(nb_samples:end,:));
    else
       mode{idx_freq}='CW'; 
    end
end
data_c=data;