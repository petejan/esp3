function [Sv_f,f_vec]=processSv_f_r(Transceiver,EnvData,iPing,r1,r2,cal,cal_eba)


if strcmp(Transceiver.Mode,'FM')
    Rwt_rx=1e3;%ohms
    Ztrd=75;%ohms
    
    
    f_s_sig=round(1/(Transceiver.Params.SampleInterval(1)));
    c=(EnvData.SoundSpeed);
    FreqStart=(Transceiver.Params.FrequencyStart(1));
    FreqEnd=(Transceiver.Params.FrequencyEnd(1));
    Freq=(Transceiver.Config.Frequency);
    ptx=(Transceiver.Params.TransmitPower(1));
    pulse_length=(Transceiver.Params.PulseLength(1));
    gains=Transceiver.Config.Gain;
    pulse_lengths=Transceiver.Config.PulseLength;
    eq_beam_angle=Transceiver.Config.EquivalentBeamAngle;
    [~,idx_pulse]=nanmin(abs(pulse_lengths-pulse_length));
    gain=gains(idx_pulse);
    FreqCenter=(FreqStart+FreqEnd)/2;
    
    
    
    [simu_pulse,~]=generate_sim_pulse(Transceiver.Params,Transceiver.Filters(1),Transceiver.Filters(2));
    
    range=Transceiver.Data.get_range();
    
    nb_samples=length(range);
    nb_pings=length(Transceiver.Data.Time);
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
    
    y_c=Transceiver.Data.get_subdatamat(idx_r1:idx_r2,iPing,'field','y_real')+1i*Transceiver.Data.get_subdatamat(idx_r1:idx_r2,iPing,'field','y_imag');
    y_spread=y_c.*range_mat(idx_r1:idx_r2,iPing);
    
    w_h=hann(N_w)/(nansum(hann(N_w))/sqrt(N_w));
    
    fft_vol=fft(w_h.*(y_spread),nfft)/nfft;
    
    y_tx_auto=xcorr(simu_pulse)/nansum(abs(simu_pulse).^2);
    t_eff_c=nansum(abs(y_tx_auto).^2)/(nanmax(abs(y_tx_auto).^2)*f_s_sig);
    
    fft_pulse=(fft(y_tx_auto,nfft))/nfft;
    
    
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
        Gf_corr=interp1(cal.freq_vec,cal.Gf,f_vec);
         idx_null=abs((cal.th_ts)-10*log10(nanmean(10.^(cal.th_ts/10))))>5;
        cal.Gf(idx_null)=nan;
    else
        Gf_corr=0;
        idx_null=[];
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
    
    gain_f=gain +20*log10(f_vec./Freq);
    
    
    alpha_f=nan(size(f_vec));
    r=round(range(idx_r));
    for jj=1:length(f_vec)
        alpha_f(jj)=  sw_absorption(f_vec(jj)/1e3, (EnvData.Salinity), (EnvData.Temperature), r,'fandg')/1e3;
    end
    
    
    Prx_fft_vol=4*(abs(fft_vol_norm)/(2*sqrt(2))).^2*((Rwt_rx+Ztrd)/Rwt_rx)^2/Ztrd;
    
    Sv_f=10*log10(Prx_fft_vol)+2*alpha_f.*r-10*log10(c*t_eff_c/2)-10*log10(ptx*lambda.^2/(16*pi^2))-2*(gain_f+Gf_corr)-eq_beam_angle_f;
    %Sp_f=10*log10(Prx_fft_target)+40*log10(r_ts(idx_max))+2*alpha_f.*r_ts(idx_max)-10*log10(ptx*lambda.^2/(16*pi^2))-2*(gain_f+Gf_corr);

else
    Sv_f=[];
    f_vec=[];
    fprintf('%s not in  FM mode\n',Transceiver.Config.ChannelID);
end


end
