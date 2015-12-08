function [data_c,mode]=match_filter_data(data)

mode=cell(1,length(data.config));
for idx_freq=1:length(data.params)
    if data.params(idx_freq).FrequencyStart(1)~=data.params(idx_freq).FrequencyEnd(1) 
        mode{idx_freq}='FM';
        
        [sim_pulse,y_tx_matched]=generate_sim_pulse(data.params(idx_freq),data.filter_coeff(idx_freq).stages(1),data.filter_coeff(idx_freq).stages(2));
        
        s1=data.pings(idx_freq).comp_sig_1;
        s2=data.pings(idx_freq).comp_sig_2;
        s3=data.pings(idx_freq).comp_sig_3;
        s4=data.pings(idx_freq).comp_sig_4;
        
        [~,nb_pings]=size(s1);
        
        data.pings(idx_freq).ping_num=(1:nb_pings);
               
        data.pings(idx_freq).match_filter=y_tx_matched;
        data.pings(idx_freq).simu_pulse=sim_pulse;
        
        yc_1=nan(size(s1));
        yc_2=nan(size(s1));
        yc_3=nan(size(s1));
        yc_4=nan(size(s1));
        
%         
%         for i=1:nb_pings
%             yc_1_temp=conv(s1(:,i),y_tx_matched,'full')/nansum(abs(y_tx_matched).^2);
%             yc_2_temp=conv(s2(:,i),y_tx_matched,'full')/nansum(abs(y_tx_matched).^2);
%             yc_3_temp=conv(s3(:,i),y_tx_matched,'full')/nansum(abs(y_tx_matched).^2);
%             yc_4_temp=conv(s4(:,i),y_tx_matched,'full')/nansum(abs(y_tx_matched).^2);
%             
%             yc_1(:,i)=yc_1_temp(length(y_tx_matched):end);
%             yc_2(:,i)=yc_2_temp(length(y_tx_matched):end);
%             yc_3(:,i)=yc_3_temp(length(y_tx_matched):end);
%             yc_4(:,i)=yc_4_temp(length(y_tx_matched):end);
%         end
%         

        yc_1_temp=filter2((flipud(y_tx_matched)),s1,'full')/nansum(abs(y_tx_matched).^2); 
        yc_2_temp=filter2((flipud(y_tx_matched)),s2,'full')/nansum(abs(y_tx_matched).^2); 
        yc_3_temp=filter2((flipud(y_tx_matched)),s3,'full')/nansum(abs(y_tx_matched).^2); 
        yc_4_temp=filter2((flipud(y_tx_matched)),s4,'full')/nansum(abs(y_tx_matched).^2); 
        
        
        yc_1=yc_1_temp(length(y_tx_matched):end,:);
        yc_2=yc_2_temp(length(y_tx_matched):end,:);
        yc_3=yc_3_temp(length(y_tx_matched):end,:);
        yc_4=yc_4_temp(length(y_tx_matched):end,:);
        
        data.pings(idx_freq).comp_sig_1=yc_1;
        data.pings(idx_freq).comp_sig_2=yc_2;
        data.pings(idx_freq).comp_sig_3=yc_3;
        data.pings(idx_freq).comp_sig_4=yc_4;
    else
       mode{idx_freq}='CW'; 
    end
end
data_c=data;