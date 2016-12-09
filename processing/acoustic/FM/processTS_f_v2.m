function [Sp_f,compensation_f,f_vec,r_tot]=processTS_f_v2(Transceiver,EnvData,iPing,r,dp,cal)

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
    [~,idx_pulse]=nanmin(abs(pulse_lengths-pulse_length));
    gain=gains(idx_pulse);
    eq_beam_angle=Transceiver.Config.EquivalentBeamAngle;
    
    dr=pulse_length*c/(4*dp);
    
    nfft=ceil(pulse_length*f_s_sig/dp);
    
    range=Transceiver.Data.get_range();
    
    idx_ts=find(range>=nanmin(r)-dr&range<=nanmax(r)+dr);
    
    idx_ts=idx_ts(1:nanmin(length(r)*nfft,length(idx_ts)));
    
    
    
    y_c_ts=Transceiver.Data.get_subdatamat(idx_ts,iPing,'field','y_real')+1i*Transceiver.Data.get_subdatamat(idx_ts,iPing,'field','y_imag');
    AlongAngle_val=Transceiver.Data.get_subdatamat(idx_ts,iPing,'field','AlongAngle');
    AcrossAngle_val=Transceiver.Data.get_subdatamat(idx_ts,iPing,'field','AcrossAngle');
    
    r_ts=range(idx_ts);
    
    [~,idx_max]=nanmax(y_c_ts);
    
    [simu_pulse,~]=generate_sim_pulse(Transceiver.Params,Transceiver.Filters(1),Transceiver.Filters(2));
    
    y_tx_auto=xcorr(simu_pulse)/nansum(abs(simu_pulse).^2);
    
    if nfft<length(y_tx_auto)
        y_tx_auto_red=y_tx_auto(ceil(length(y_tx_auto)/2)-floor(nfft/2)+1:ceil(length(y_tx_auto)/2)-floor(nfft/2)+nfft);
    else
        y_tx_auto_red=y_tx_auto;
    end
    
    
    %win=hanning(nfft);
    win=ones(nfft,1);
    
    fft_pulse=(fft(y_tx_auto_red,nfft))/nfft;
    
    if length(y_c_ts)<=nfft
        s = fft(y_c_ts,nfft)/nfft;
    else
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
    
    BeamWidthAlongship_f=Transceiver.Config.BeamWidthAlongship*acos(1-(10.^(eq_beam_angle_f/10))/(2*pi))/acos(1-(10.^(eq_beam_angle/20))/(2*pi));
    BeamWidthAthwartship_f=Transceiver.Config.BeamWidthAthwartship*acos(1-(10.^(eq_beam_angle_f/10))/(2*pi))/acos(1-(10.^(eq_beam_angle/20))/(2*pi));
    
    for jj=1:length(f_vec)
        compensation_f(:,jj) = simradBeamCompensation(BeamWidthAlongship_f(jj),BeamWidthAthwartship_f(jj) , AlongAngle_val, AcrossAngle_val);
        alpha_f(:,jj)=  sw_absorption(f_vec(jj)/1e3, (EnvData.Salinity), (EnvData.Temperature), r_ts(idx_max),'fandg')/1e3;
    end
    
    compensation_f(compensation_f<0)=nan;
    compensation_f(compensation_f>12)=nan;
    
    
    if ~isempty(cal)
        Gf_corr=interp1(cal.freq_vec,cal.Gf,f_vec);
        %         idx_null=abs((cal.th_ts)-10*log10(nanmean(10.^(cal.th_ts/10))))>5;
        %         cal.Gf(idx_null)=nan;
        idx_null=nan;
    else
        Gf_corr=0;
        idx_null=nan;
    end
    
    gain_f=gain + 20*log10(f_vec./Freq);
    
    lambda=c./(f_vec);
    
    Prx_fft=4*(abs(s_norm)/(2*sqrt(2))).^2*((Rwt_rx+Ztrd)/Rwt_rx)^2/Ztrd;
    
    
    Sp_f=bsxfun(@minus,bsxfun(@plus,10*log10(Prx_fft)+bsxfun(@times,2*alpha_f,r_tot),40*log10(r_tot)),10*log10(ptx*lambda.^2/(16*pi^2))+2*(gain_f+Gf_corr));
    
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
    fprintf('%s not in  FM mode\n',Transceiver.Config.ChannelID);
end

end
