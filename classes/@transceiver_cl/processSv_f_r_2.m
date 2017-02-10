function [Sv_f,f_vec,r]=processSv_f_r_2(trans_obj,EnvData,iPing,r,Nw,cal,cal_eba)


if strcmp(trans_obj.Mode,'FM')
    Rwt_rx=trans_obj.Config.Impedance;
    Ztrd=trans_obj.Config.Ztrd;
    
    
    f_s_sig=(1/(trans_obj.Params.SampleInterval(1)));
    c=(EnvData.SoundSpeed);
    FreqStart=(trans_obj.Params.FrequencyStart(1));
    FreqEnd=(trans_obj.Params.FrequencyEnd(1));
    Freq=(trans_obj.Config.Frequency);
    ptx=(trans_obj.Params.TransmitPower(1));
    pulse_length=(trans_obj.Params.PulseLength(1));
    
    eq_beam_angle=trans_obj.Config.EquivalentBeamAngle;
    
    
    gain=trans_obj.get_current_gain();
    

    range=trans_obj.get_transceiver_range();
    nb_samples=length(range);
    dr=nanmean(diff(range));
    Np=2^nextpow2(ceil(2*pulse_length*f_s_sig));

    if isempty(Nw)
        Nw=nanmax(length(r),Np);
        Nw=2^(nextpow2(Nw)-1);
    else
       Nw=2^(nextpow2(Nw)); 
    end
    
    

    [~,idx_r1]=nanmin(abs(range-(r(1)-Np/2*dr)));
    [~,idx_r2]=nanmin(abs(range-(r(end)+Np/2*dr)));
    
    idx_r1=nanmax(idx_r1,1);
    idx_r2=nanmin(idx_r2,nb_samples);
    
    if (idx_r2-idx_r1)<Nw
        idx_r=round((idx_r1+idx_r2)/2);
        idx_r1=nanmax(idx_r-Nw/2+1,1);
        idx_r2=nanmin(idx_r1+Nw-1,nb_samples);
    end

    y_c=trans_obj.Data.get_subdatamat(idx_r1:idx_r2,iPing,'field','y_real')+1i*trans_obj.Data.get_subdatamat(idx_r1:idx_r2,iPing,'field','y_imag');
   
    r=range(idx_r1:idx_r2);
    y_spread=y_c.*r;
    

    if length(y_spread)<=Nw
         w_h=hann(length(y_spread))/(nansum(hann(length(y_spread)))/sqrt(length(y_spread)));
        fft_vol=fft(w_h(1:length(y_spread)).*(y_spread),Nw)/Nw;
    else   
        w_h=hann(Nw)/(nansum(hann(Nw))/sqrt(Nw));
        fft_vol = spectrogram(y_spread,w_h,Nw-1,Nw)/Nw;
    end

    
    [~,y_tx_matched]=generate_sim_pulse(trans_obj.Params,trans_obj.Filters(1),trans_obj.Filters(2));

    y_tx_auto=xcorr(y_tx_matched)/nansum(abs(y_tx_matched).^2);
    
    if Nw<length(y_tx_auto)
        y_tx_auto_red=y_tx_auto(ceil(length(y_tx_auto)/2)-floor(Nw/2)+1:ceil(length(y_tx_auto)/2)-floor(Nw/2)+Nw);
    else
        y_tx_auto_red=y_tx_auto;
    end
    
    fft_pulse=(fft(y_tx_auto_red,Nw))/Nw;
    fft_vol_norm=bsxfun(@rdivide,fft_vol,fft_pulse);
 
    n_rep=ceil(FreqEnd/f_s_sig);
    
    f_vec_rep=f_s_sig*(0:Nw*n_rep-1)/Nw;
    
    fft_vol_norm_rep=repmat(fft_vol_norm,n_rep,1);
    idx_vec=f_vec_rep>=FreqStart&f_vec_rep<=FreqEnd;
    f_vec=f_vec_rep(idx_vec);
    fft_vol_norm=fft_vol_norm_rep(idx_vec,:)';
    
    idx_val=floor(Nw/2):floor(Nw/2)+size(fft_vol_norm,1)-1;
    r=r(idx_val);
    alpha_f=nan(length(r),length(f_vec));   

    
    for jj=1:length(f_vec)
        alpha_f(:,jj)=  sw_absorption(f_vec(jj)/1e3, (EnvData.Salinity), (EnvData.Temperature), r,'fandg')/1e3;
    end
    
    
    lambda=c./(f_vec);
    
    
    eq_beam_angle_f=eq_beam_angle-20*log10(f_vec/Freq);
    
    if ~isempty(cal)
        Gf=interp1(cal.freq_vec,cal.Gf,f_vec);
    else
        Gf=gain+10*log10(f_vec./Freq);
    end


    
    
    Prx_fft_vol=4*(abs(fft_vol_norm)/(2*sqrt(2))).^2*((Rwt_rx+Ztrd)/Rwt_rx)^2/Ztrd;
    tw=Nw/f_s_sig;
%    Sv_f=10*log10(Prx_fft_vol(:))+2*alpha_f(:).*r-10*log10(c*tw/2)-10*log10(ptx*lambda(:).^2/(16*pi^2))-2*(Gf(:))-eq_beam_angle_f(:);
    Sv_f=bsxfun(@minus,10*log10(Prx_fft_vol)+bsxfun(@times,2*alpha_f,r),10*log10(c*tw/2)+10*log10(ptx*lambda.^2/(16*pi^2))+2*(Gf)+eq_beam_angle_f);
  
else
    Sv_f=[];
    f_vec=[];
    fprintf('%s not in  FM mode\n',trans_obj.Config.ChannelID);
end


end
