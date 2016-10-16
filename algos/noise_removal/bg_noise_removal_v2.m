function [power_unoised,Sv_unoised,Sp_unoised,SNR]=bg_noise_removal_v2(trans_obj,varargin)

range=trans_obj.Data.get_range();
p = inputParser;

defaultVertFilt=5;
checkVertFilt=@(VertFilt)(VertFilt>0&&VertFilt<=range(end));
defaultHorzFilt=20;
checkHorzFilt=@(HorzFilt)(HorzFilt>0&&HorzFilt<=1000);
defaultNoiseThr=-125;
checkNoiseThr=@(NoiseThr)(NoiseThr<=-10&&NoiseThr>=-200);
defaultSNRThr=10;
checkSNRThr=@(SNRThr)(SNRThr>=0&&SNRThr<=40);

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));

addParameter(p,'VertFilt',defaultVertFilt,checkVertFilt);
addParameter(p,'HorzFilt',defaultHorzFilt,checkHorzFilt);
addParameter(p,'NoiseThr',defaultNoiseThr,checkNoiseThr);
addParameter(p,'SNRThr',defaultSNRThr,checkSNRThr);
addParameter(p,'load_bar_comp',[]);

parse(p,trans_obj,varargin{:});


f_s_sig=round(1/(trans_obj.Params.SampleInterval(1)));
c=1500;
FreqStart=(trans_obj.Params.FrequencyStart(1));
FreqEnd=(trans_obj.Params.FrequencyEnd(1));
Freq=(trans_obj.Config.Frequency);
ptx=(trans_obj.Params.TransmitPower(1));
pulse_length=double(trans_obj.Params.PulseLength(1));
gains=trans_obj.Config.Gain;
pulse_lengths=trans_obj.Config.PulseLength;
eq_beam_angle=trans_obj.Config.EquivalentBeamAngle;
[~,idx_pulse]=nanmin(abs(pulse_lengths-pulse_length));
gain=gains(idx_pulse);
FreqCenter=(FreqStart+FreqEnd)/2;
lambda=c/FreqCenter;
eq_beam_angle=eq_beam_angle+20*log10(Freq/(FreqCenter));
alpha=double(trans_obj.Params.Absorption(1));
sacorr=2*trans_obj.Config.SaCorrection(idx_pulse);

if strcmp(trans_obj.Mode,'FM')
    [simu_pulse,~]=generate_sim_pulse(trans_obj.Params,trans_obj.Filters(1),trans_obj.Filters(2));
    pulse_auto_corr=xcorr(simu_pulse)/nansum(abs(simu_pulse).^2);
    t_eff=nansum(abs(pulse_auto_corr).^2)/(nanmax(abs(pulse_auto_corr).^2)*f_s_sig);
else
    t_eff=pulse_length;
end
power=trans_obj.Data.get_datamat('Power');
if isempty(power)
    power_unoised=[];Sv_unoised=[];Sp_unoised=[];SNR=[];
end


h_filt=ceil(nanmin(p.Results.VertFilt,size(power,1))/nanmean(diff(range)));
w_filt=nanmin(p.Results.HorzFilt,size(power,2));
noise_thr=p.Results.NoiseThr;
SNR_thr=p.Results.SNRThr;

power_filt=filter2_perso(ones(h_filt,w_filt),power);

% idx_valid=(power>0);
% idx_valid=filter2_perso(ones(h_filt,w_filt),idx_valid);
% power_filt(idx_valid==0)=nan;

[noise_db,~]=nanmin(10*log10(power_filt(range>nanmean(range)/2,:)),[],1);

power_noise_db=bsxfun(@times,noise_db,ones(size(power,1),1));
power_noise_db(power<0)=nan;
power_noise_db(power_noise_db>noise_thr)=noise_thr;

power_noise=10.^(power_noise_db/10);
power_unoised=power-power_noise;
power_unoised(power_unoised<=0)=nan;


[sp,sv]=convert_power_lin(power,range,c,alpha,t_eff,double(ptx),lambda,gain,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);  
[sp_noise,sv_noise]=convert_power_lin(power_noise,range,c,alpha,t_eff,double(ptx),lambda,gain,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);

Sp_unoised_lin=sp-sp_noise;
Sp_unoised_lin(Sp_unoised_lin<=0)=nan;
Sp_unoised=10*log10(Sp_unoised_lin);


Sv_unoised_lin=sv-sv_noise;
Sv_unoised_lin(Sv_unoised_lin<=0)=nan;
Sv_unoised=10*log10(Sv_unoised_lin);


SNR=Sv_unoised-pow2db_perso(sv_noise);
power_unoised(SNR<SNR_thr)=0;
Sp_unoised(SNR<SNR_thr)=-999;
Sv_unoised(SNR<SNR_thr)=-999;

power_unoised(isnan(power_unoised))=0;
Sp_unoised(isnan(Sp_unoised))=-999;
Sv_unoised(isnan(Sv_unoised))=-999;


end

