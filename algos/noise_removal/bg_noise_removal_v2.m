function [pow_unoised,Sv_unoised,Sp_unoised,SNR]=bg_noise_removal_v2(trans_obj,varargin)

range_t=trans_obj.get_transceiver_range();
p = inputParser;

defaultVertFilt=5;
checkVertFilt=@(VertFilt)(VertFilt>0&&VertFilt<=range_t(end));
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
addParameter(p,'block_len',1e7,@(x) x>0);
addParameter(p,'load_bar_comp',[]);

parse(p,trans_obj,varargin{:});

c=1500;
FreqStart=(trans_obj.Params.FrequencyStart(1));
FreqEnd=(trans_obj.Params.FrequencyEnd(1));
Freq=(trans_obj.Config.Frequency);
ptx=(trans_obj.Params.TransmitPower);
pulse_length=trans_obj.get_pulse_length(1);
eq_beam_angle=trans_obj.Config.EquivalentBeamAngle;
gain=trans_obj.get_current_gain();

FreqCenter=(FreqStart+FreqEnd)/2;
lambda=c/FreqCenter;
eq_beam_angle=eq_beam_angle+20*log10(Freq/(FreqCenter));
alpha=double(trans_obj.Params.Absorption(1));
cal=trans_obj.get_cal();
sacorr=2*cal.SACORRECT;

pings_tot=trans_obj.get_transceiver_pings();


if strcmp(trans_obj.Mode,'FM')
    [t_eff,~]=trans_obj.get_pulse_Teff();
else
    t_eff=pulse_length;
end

switch trans_obj.Config.TransceiverType
    case list_WBTs()
        [t_nom,~]=trans_obj.get_pulse_length(1);
    otherwise
        t_nom=0;
end

nb_pings_tot=numel(pings_tot);

block_size=ceil(p.Results.block_len/numel(range_t));
block_size=nanmin(ceil(block_size/p.Results.HorzFilt)*p.Results.HorzFilt,nb_pings_tot);
num_ite=ceil(nb_pings_tot/block_size);

if ~isempty(p.Results.load_bar_comp)
    set(p.Results.load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',num_ite, 'Value',0);
end

idx_pings_tot=1:nb_pings_tot;
idx_r=1:numel(range_t);
for ui=1:num_ite
    idx_pings=idx_pings_tot((ui-1)*block_size+1:nanmin(ui*block_size,numel(idx_pings_tot)));
    
    pow = trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','power');
    
    if isempty(pow)
        pow_unoised=[];Sv_unoised=[];Sp_unoised=[];SNR=[];
        return;
    end
    
    
    h_filt=ceil(nanmin(p.Results.VertFilt,size(pow,1))/nanmax(diff(range_t)));
    w_filt=nanmin(p.Results.HorzFilt,size(pow,2));
    noise_thr=p.Results.NoiseThr;
    SNR_thr=p.Results.SNRThr;
    
    pow_filt=filter2_perso(ones(h_filt,w_filt),pow);
    
    % idx_valid=(pow>0);
    % idx_valid=filter2_perso(ones(h_filt,w_filt),idx_valid);
    % pow_filt(idx_valid==0)=nan;
    
    [noise_db,~]=nanmin(10*log10(pow_filt(range_t>nanmean(range_t)/2,:)),[],1);
    
    pow_noise_db=bsxfun(@times,noise_db,ones(size(pow,1),1));
    pow_noise_db(pow<0)=nan;
    pow_noise_db(pow_noise_db>noise_thr)=noise_thr;
    
    pow_noise=10.^(pow_noise_db/10);
    pow_unoised=pow-pow_noise;
    pow_unoised(pow_unoised<=0)=nan;
    
    
    [sp,sv]=convert_power_lin(pow,range_t,c,alpha,t_eff,t_nom,double(ptx(idx_pings)),lambda,gain,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);
    [sp_noise,sv_noise]=convert_power_lin(pow_noise,range_t,c,alpha,t_eff,t_nom,double(ptx(idx_pings)),lambda,gain,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);
    
    Sp_unoised_lin=sp-sp_noise;
    Sp_unoised_lin(Sp_unoised_lin<=0)=nan;
    Sp_unoised=10*log10(Sp_unoised_lin);
    
    
    Sv_unoised_lin=sv-sv_noise;
    Sv_unoised_lin(Sv_unoised_lin<=0)=nan;
    Sv_unoised=10*log10(Sv_unoised_lin);
    
    
    SNR=Sv_unoised-pow2db_perso(sv_noise);
    pow_unoised(SNR<SNR_thr)=0;
    Sp_unoised(SNR<SNR_thr)=-999;
    Sv_unoised(SNR<SNR_thr)=-999;
    
    pow_unoised(isnan(pow_unoised))=0;
    Sp_unoised(isnan(Sp_unoised))=-999;
    Sv_unoised(isnan(Sv_unoised))=-999;
    SNR(isnan(SNR))=-999;
    %trans_obj.Data.replace_sub_data_v2('powerdenoised',pow_unoised,idx_pings,0);
    trans_obj.Data.replace_sub_data_v2('spdenoised',Sp_unoised,idx_pings,-999);
    trans_obj.Data.replace_sub_data_v2('svdenoised',Sv_unoised,idx_pings,-999);
    trans_obj.Data.replace_sub_data_v2('snr',SNR,idx_pings,-999);
    clear Sp_unoised Sv_unoised snr pow     
    if ~isempty(p.Results.load_bar_comp)
        set(p.Results.load_bar_comp.progress_bar, 'Value',ui);
    end
end
end



