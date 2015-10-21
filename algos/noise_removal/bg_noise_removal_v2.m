function [power_unoised,Sv_unoised,Sp_unoised,SNR]=bg_noise_removal_v2(power,range,c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle,sacorr,varargin)
removing_noise=msgbox('Removing Noise. This box will close when finished...','Removing Noise');
p = inputParser;

defaultVertFilt=5;
checkVertFilt=@(VertFilt)(VertFilt>0&&VertFilt<=range(end));
defaultHorzFilt=20;
checkHorzFilt=@(HorzFilt)(HorzFilt>0&&HorzFilt<=1000);
defaultNoiseThr=-125;
checkNoiseThr=@(NoiseThr)(NoiseThr<=-10&&NoiseThr>=-200);
defaultSNRThr=10;
checkSNRThr=@(SNRThr)(SNRThr>0&&SNRThr<=40);

addRequired(p,'power',@isnumeric);
addRequired(p,'range',@isnumeric);
addRequired(p,'c',@isnumeric);
addRequired(p,'alpha',@isnumeric);
addRequired(p,'t_eff',@isnumeric);
addRequired(p,'ptx',@isnumeric);
addRequired(p,'lambda',@isnumeric);
addRequired(p,'gain',@isnumeric);
addRequired(p,'eq_beam_angle',@isnumeric);
addRequired(p,'sacorr',@isnumeric);

addParameter(p,'VertFilt',defaultVertFilt,checkVertFilt);
addParameter(p,'HorzFilt',defaultHorzFilt,checkHorzFilt);
addParameter(p,'NoiseThr',defaultNoiseThr,checkNoiseThr);
addParameter(p,'SNRThr',defaultSNRThr,checkSNRThr);

parse(p,power,range,c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle,sacorr,varargin{:});


h_filt=ceil(nanmin(p.Results.VertFilt,size(power,1))/nanmean(diff(range)));
w_filt=nanmin(p.Results.HorzFilt,size(power,2));
noise_thr=p.Results.NoiseThr;
SNR_thr=p.Results.SNRThr;


power_filt=filter2_perso(ones(h_filt,w_filt),power);

% idx_valid=(power>0);
% idx_valid=filter2_perso(ones(h_filt,w_filt),idx_valid);
% power_filt(idx_valid==0)=nan;

[noise_db,~]=nanmin(10*log10(power_filt(range>nanmean(range)/2,:)),[],1);

power_noise_db=repmat(noise_db,size(power,1),1);
power_noise_db(power<0)=nan;
power_noise_db(power_noise_db>noise_thr)=noise_thr;

power_noise=10.^(power_noise_db/10);
power_unoised=power-power_noise;
power_unoised(power_unoised<=0)=nan;

[Sp,Sv]=convert_power(power,range,c,alpha,t_eff,double(ptx),lambda,gain,eq_beam_angle,sacorr);  
[Sp_noise,Sv_noise]=convert_power(power_noise,range,c,alpha,t_eff,double(ptx),lambda,gain,eq_beam_angle,sacorr);


% [Sp_unoised,Sv_unoised]=convert_power(power_unoised,range,c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle,sacorr);

Sp_unoised_lin=(10.^(Sp/10)-10.^(Sp_noise/10));
Sp_unoised_lin(Sp_unoised_lin<=0)=nan;
Sp_unoised=10*log10(Sp_unoised_lin);

Sv_unoised_lin=(10.^(Sv/10)-10.^(Sv_noise/10));
Sv_unoised_lin(Sv_unoised_lin<=0)=nan;
Sv_unoised=10*log10(Sv_unoised_lin);


% figure();
% plot(range,Sv(:,200),'.-b');
% hold on
% plot(range,Sv_noise(:,200),'.-r');
% plot(range,Sv_unoised(:,200),'.-k');
% grid on;
% xlabel('Range (m)')
% ylabel('Sv (dB)')


SNR=Sv_unoised-Sv_noise;
power_unoised(SNR<SNR_thr)=0;
Sp_unoised(SNR<SNR_thr)=-999;
Sv_unoised(SNR<SNR_thr)=-999;

try 
    close(removing_noise)
end

end

