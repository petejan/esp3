function [Sv_f,f_vec]=processSv_f_r(trans_obj,EnvData,iPing,r1,r2,cal,cal_eba)


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
    
    
    

    range=trans_obj.Data.get_range();
    
    nb_samples=length(range);
    nb_pings=length(trans_obj.Data.Time);
    range_mat=repmat(range,1,nb_pings);
    N_w=2^nextpow2(ceil(2*pulse_length*f_s_sig));
    
    [~,idx_r1]=nanmin(abs(range-r1));
    [~,idx_r2]=nanmin(abs(range-r2));
    
    
    idx_r1=nanmax(idx_r1,1);
    idx_r2=nanmin(idx_r2,nb_samples);
    
    if (idx_r2-idx_r1)<N_w
        idx_r=round((idx_r1+idx_r2)/2);
        idx_r1=nanmax(idx_r-N_w/2+1,1);
        idx_r2=nanmin(idx_r1+N_w-1,nb_samples);
    end
    
    nfft=2^nextpow2(ceil(idx_r2-idx_r1+1));
    
    idx_r=round((idx_r1+idx_r2)/2);
    N_w=length(idx_r1:idx_r2);
    
    y_c=trans_obj.Data.get_subdatamat(idx_r1:idx_r2,iPing,'field','y_real')+1i*trans_obj.Data.get_subdatamat(idx_r1:idx_r2,iPing,'field','y_imag');
    y_spread=y_c.*range_mat(idx_r1:idx_r2,iPing);
    
    w_h=hann(N_w)/(nansum(hann(N_w))/sqrt(N_w));
    
    fft_vol=fft(w_h.*(y_spread),nfft)/nfft;
    
    [~,y_tx_matched]=generate_sim_pulse(trans_obj.Params,trans_obj.Filters(1),trans_obj.Filters(2));

    y_tx_auto=xcorr(y_tx_matched)/nansum(abs(y_tx_matched).^2);
    t_eff_c=nansum(abs(y_tx_auto).^2)/(nanmax(abs(y_tx_auto).^2)*f_s_sig);
    
    fft_pulse=(fft(y_tx_auto,nfft))/nfft/2;
       
    fft_vol_norm=(fft_vol./fft_pulse);
    
    n_rep=ceil(FreqEnd/f_s_sig);
    
    f_vec_rep=f_s_sig*(0:nfft*n_rep-1)/nfft;
    
    fft_vol_norm_rep=repmat(fft_vol_norm,1,n_rep);
    idx_vec=f_vec_rep>=FreqStart&f_vec_rep<=FreqEnd;
    f_vec=f_vec_rep(idx_vec);
    fft_vol_norm=fft_vol_norm_rep(idx_vec);
    
    
    lambda=c./(f_vec);
    
    
    eq_beam_angle_f=eq_beam_angle-20*log10(f_vec/Freq);
    
    if ~isempty(cal)
        Gf=interp1(cal.freq_vec,cal.Gf,f_vec);
    else
        Gf=gain+10*log10(f_vec./Freq);
    end
    
    
    % if ~isempty(cal_eba)
    %     cal_eba.BeamWidthAlongship_f_fit(idx_null)=nan;
    %     cal_eba.BeamWidthAthwartship_f_fit(idx_null)=nan;
    %     eba=10*log10(2.2578*sind(cal_eba.BeamWidthAlongship_f_fit/4+cal_eba.BeamWidthAthwartship_f_fit/4).^2);
    %     eq_beam_angle_f=interp1(cal_eba.freq_vec,eba,f_vec);
    % end
    
    
    
    % figure(12312);
    % hold on;
    % plot(f_vec,Gf_corr);
    % grid on;
    
    
    
    alpha_f=nan(size(f_vec));
    r=round(range(idx_r));
    for jj=1:length(f_vec)
        alpha_f(jj)=  sw_absorption(f_vec(jj)/1e3, (EnvData.Salinity), (EnvData.Temperature), r,'fandg')/1e3;
    end
    
    
    Prx_fft_vol=4*(abs(fft_vol_norm)/(2*sqrt(2))).^2*((Rwt_rx+Ztrd)/Rwt_rx)^2/Ztrd;
    %tw=nfft/f_s_sig;
    Sv_f=10*log10(Prx_fft_vol)+2*alpha_f.*r-10*log10(c*t_eff_c/2)-10*log10(ptx*lambda.^2/(16*pi^2))-2*(Gf)-eq_beam_angle_f;
    %Sp_f=10*log10(Prx_fft_target)+40*log10(r_ts(idx_max))+2*alpha_f.*r_ts(idx_max)-10*log10(ptx*lambda.^2/(16*pi^2))-2*(gain_f+Gf_corr);
    
else
    Sv_f=[];
    f_vec=[];
    fprintf('%s not in  FM mode\n',trans_obj.Config.ChannelID);
end


end
