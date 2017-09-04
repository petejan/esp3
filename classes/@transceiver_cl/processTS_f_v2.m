function [Sp_f,compensation_f,f_vec,r_tot]=processTS_f_v2(trans_obj,EnvData,iPing,r,dp,cal,att_model)
if isempty(att_model)
    att_model='doonan';
end


if strcmp(trans_obj.Mode,'FM')
    Rwt_rx=trans_obj.Config.Impedance;
    Ztrd=trans_obj.Config.Ztrd;
    
    
    f_s_sig=round(1/(trans_obj.Params.SampleInterval(1)));
    c=(EnvData.SoundSpeed);
    FreqStart=(trans_obj.Params.FrequencyStart(1));
    FreqEnd=(trans_obj.Params.FrequencyEnd(1));
    Freq=(trans_obj.Config.Frequency);
    
    if FreqEnd>120000
        att_model='fandg';
    end
        
    
    ptx=(trans_obj.Params.TransmitPower(1));
    pulse_length=(trans_obj.Params.PulseLength(1));
    
    gain=trans_obj.get_current_gain();
    
    eq_beam_angle=trans_obj.Config.EquivalentBeamAngle;
    
    dr=pulse_length*c/(4*dp);
    
    nfft=ceil(pulse_length*f_s_sig/dp);
    nfft=2^(nextpow2(nfft));
    
    range=trans_obj.get_transceiver_range();
    
    idx_ts=find(range>=nanmin(r)-dr&range<=nanmax(r)+dr);
    
    idx_ts=idx_ts(1:nanmin(length(r)*nfft,length(idx_ts)));
    
    
    
    y_c_ts=trans_obj.Data.get_subdatamat(idx_ts,iPing,'field','y_real')+1i*trans_obj.Data.get_subdatamat(idx_ts,iPing,'field','y_imag');
    AlongAngle_val=trans_obj.Data.get_subdatamat(idx_ts,iPing,'field','AlongAngle');
    AcrossAngle_val=trans_obj.Data.get_subdatamat(idx_ts,iPing,'field','AcrossAngle');
    
    r_ts=range(idx_ts);
    

    [~,y_tx_matched]=generate_sim_pulse(trans_obj.Params,trans_obj.Filters(1),trans_obj.Filters(2));
    

    y_tx_auto=xcorr(y_tx_matched)/nansum(abs(y_tx_matched).^2);
    
    if nfft<length(y_tx_auto)
        y_tx_auto_red=y_tx_auto(ceil(length(y_tx_auto)/2)-floor(nfft/2)+1:ceil(length(y_tx_auto)/2)-floor(nfft/2)+nfft);
    else
        y_tx_auto_red=y_tx_auto;
    end
    
    
      
    fft_pulse=(fft(y_tx_auto_red,nfft))/nfft;
    
    if length(y_c_ts)<=nfft
        win=hann(length(y_c_ts));
        win=win/nanmax(win);
        s = fft(win.*y_c_ts,nfft)/nfft;
    else
        win=hann(nfft);win=win/nanmax(win);
        s = spectrogram(y_c_ts,win,nfft-1,nfft)/nfft;
    end
    
    s_norm=bsxfun(@rdivide,s,fft_pulse);
    
    n_rep=ceil(FreqEnd/f_s_sig);
    
    f_vec_rep=f_s_sig*(0:nfft*n_rep-1)/nfft;
    
    
    s_norm_rep=repmat(s_norm,n_rep,1);
    
    idx_vec=f_vec_rep>=FreqStart&f_vec_rep<=FreqEnd;
    f_vec=f_vec_rep(idx_vec);
    
    s_norm=s_norm_rep(idx_vec,:)';
    
    idx_val=floor(nfft/2):floor(nfft/2)+size(s_norm,1)-1;
    
    r_tot=r_ts(idx_val);
    AlongAngle_val=AlongAngle_val(idx_val);
    AcrossAngle_val=AcrossAngle_val(idx_val);
    
    alpha_f=nan(length(AlongAngle_val),length(f_vec));
    compensation_f=nan(length(AlongAngle_val),length(f_vec));
    eq_beam_angle_f=eq_beam_angle-20*log10(f_vec/Freq);
    
    %     BeamWidthAlongship_f=trans_obj.Config.BeamWidthAlongship*acos(1-(10.^(eq_beam_angle_f/10))/(2*pi))/acos(1-(10.^(eq_beam_angle/20))/(2*pi));
    %     BeamWidthAthwartship_f=trans_obj.Config.BeamWidthAthwartship*acos(1-(10.^(eq_beam_angle_f/10))/(2*pi))/acos(1-(10.^(eq_beam_angle/20))/(2*pi));
    %
    BeamWidthAlongship_f=trans_obj.Config.BeamWidthAlongship*ones(size(eq_beam_angle_f));
    BeamWidthAthwartship_f=trans_obj.Config.BeamWidthAthwartship*ones(size(eq_beam_angle_f));
    
    
    for jj=1:length(f_vec)
        compensation_f(:,jj) = simradBeamCompensation(BeamWidthAlongship_f(jj),BeamWidthAthwartship_f(jj) , AlongAngle_val, AcrossAngle_val);
        alpha_f(:,jj)=  sw_absorption(f_vec(jj)/1e3, (EnvData.Salinity), (EnvData.Temperature), r_tot,att_model)/1e3;
    end
    
    compensation_f(compensation_f<0)=nan;
    compensation_f(compensation_f>12)=nan;
        
    if ~isempty(cal)
        Gf=interp1(cal.freq_vec,cal.Gf,f_vec);
    else
        Gf=gain +10*log10(f_vec./Freq);
    end
       
    lambda=c./(f_vec);
    
    Prx_fft=4*(abs(s_norm)/(2*sqrt(2))).^2*((Rwt_rx+Ztrd)/Rwt_rx)^2/Ztrd;
    
    
    Sp_f=bsxfun(@minus,bsxfun(@plus,10*log10(Prx_fft)+bsxfun(@times,2*alpha_f,r_tot),40*log10(r_tot)),10*log10(ptx*lambda.^2/(16*pi^2))+2*(Gf));
    
    %     figure();
    %     echo=imagesc(f_vec/1e3,r_tot,Sp_f_ping);
    %     set(echo,'AlphaData',Sp_f_ping>-50);
    %     xlabel('Frequency (kHz)');
    %     ylabel('Range(m)');
    %     caxis([-50 -35]); colormap('jet');
    %     title(sprintf('Ping %i, Frequency resolution %.1f kHz',iPing,(c/(2*dr)/1e3)));
    %
    %
    %
    %     figure();
    %      plot(f_vec/1e3,Sp_f_ping(idx_peak-floor(nfft/2):idx_peak-floor(nfft/2),:));
    %      hold on;plot(f_vec/1e3,Sp_f,'k');
    %      xlabel('Frequency (kHz)');
else
    Sp_f=[];
    compensation_f=[];
    f_vec=[];
    fprintf('%s not in  FM mode\n',trans_obj.Config.ChannelID);
end

end
