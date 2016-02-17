
function prepare_classification(layer,idx_to_process,reprocess,own)


[idx_38,found_38]=find_freq_idx(layer,38000);

if ~found_38
    warning('Cannot find 38 kHz!Pass...');
    return;
end


for uu=idx_to_process
 
    idx_school_detect=find_algo_idx(layer.Transceivers(uu),'SchoolDetection');
    idx_algo_bp=find_algo_idx(layer.Transceivers(uu),'BadPings');
    idx_algo_denoise=find_algo_idx(layer.Transceivers(uu),'Denoise');
    
    if reprocess==1||isempty(get_datamat(layer.Transceivers(uu).Data,'svdenoised'))
        
        Transceiver=layer.Transceivers(uu);
        f_s_sig=round(1/(Transceiver.Params.SampleInterval(1)));
        c=(layer.EnvData.SoundSpeed);
        FreqStart=(Transceiver.Params.FrequencyStart(1));
        FreqEnd=(Transceiver.Params.FrequencyEnd(1));
        Freq=(Transceiver.Config.Frequency);
        ptx=(Transceiver.Params.TransmitPower(1));
        pulse_length=double(Transceiver.Params.PulseLength(1));
        gains=Transceiver.Config.Gain;
        pulse_lengths=Transceiver.Config.PulseLength;
        eq_beam_angle=Transceiver.Config.EquivalentBeamAngle;
        [~,idx_pulse]=nanmin(abs(pulse_lengths-pulse_length));
        gain=gains(idx_pulse);
        FreqCenter=(FreqStart+FreqEnd)/2;
        lambda=c/FreqCenter;
        eq_beam_angle_curr=eq_beam_angle+20*log10(Freq/(FreqCenter));
        alpha=double(Transceiver.Params.Absorbtion);
        sacorr=2*Transceiver.Config.SaCorrection(idx_pulse);
        
        if strcmp(Transceiver.Mode,'FM')
            [simu_pulse,~]=generate_sim_pulse(Transceiver.Params,Transceiver.Filters(1),Transceiver.Filters(2));
            pulse_auto_corr=xcorr(simu_pulse)/nansum(abs(simu_pulse).^2);
            t_eff=nansum(abs(pulse_auto_corr).^2)/(nanmax(abs(pulse_auto_corr).^2)*f_s_sig);
        else
            t_eff=pulse_length;
        end
        
        power=layer.Transceivers(uu).Data.get_datamat('power');
        
        
        [power_unoised,Sv_denoised,Sp_denoised,SNR]=feval(layer.Transceivers(uu).Algo(idx_algo_denoise).Function,...
            power,...
            layer.Transceivers(uu).Data.Range,...
            c,alpha,t_eff,ptx,lambda,gain,eq_beam_angle_curr,sacorr,...
            'HorzFilt',layer.Transceivers(uu).Algo(idx_algo_denoise).Varargin.HorzFilt,...
            'SNRThr',3,...
            'VertFilt',layer.Transceivers(uu).Algo(idx_algo_denoise).Varargin.VertFilt,...
            'NoiseThr',layer.Transceivers(uu).Algo(idx_algo_denoise).Varargin.NoiseThr);
        
        layer.Transceivers(uu).Data.add_sub_data({'powerdenoised','spdenoised','svdenoised','snr'},{power_unoised Sp_denoised Sv_denoised SNR});
    end
    
    if reprocess==1||~strcmp(layer.Transceivers(uu).Bottom.Origin,'Algo_v2_bp')
        Sv_denoised=get_datamat(layer.Transceivers(uu).Data,'svdenoised');
        [Bottom,Double_bottom_region,idx_noise_sector]=feval(layer.Transceivers(uu).Algo(idx_algo_bp).Function,Sv_denoised,...
            layer.Transceivers(uu).Data.Range,...
            1/layer.Transceivers(uu).Params.SampleInterval(1),...
            layer.Transceivers(uu).Params.PulseLength(1),...
            'thr_bottom',layer.Transceivers(uu).Algo(idx_algo_bp).Varargin.thr_bottom,...
            'thr_echo',layer.Transceivers(uu).Algo(idx_algo_bp).Varargin.thr_echo,...
            'r_min',layer.Transceivers(uu).Algo(idx_algo_bp).Varargin.r_min,...
            'r_max',layer.Transceivers(uu).Algo(idx_algo_bp).Varargin.r_max,...
            'BS_std',layer.Transceivers(uu).Algo(idx_algo_bp).Varargin.BS_std,...
            'thr_spikes_Above',layer.Transceivers(uu).Algo(idx_algo_bp).Varargin.thr_spikes_Above,...
            'thr_spikes_Below',layer.Transceivers(uu).Algo(idx_algo_bp).Varargin.thr_spikes_Below,...
            'Above',layer.Transceivers(uu).Algo(idx_algo_bp).Varargin.Above,...
            'Below',layer.Transceivers(uu).Algo(idx_algo_bp).Varargin.Below,...
            'burst_removal',false);
        
        range=layer.Transceivers(uu).Data.Range;
        bottom_range=nan(size(Bottom));
        bottom_range(~isnan(Bottom))=range(Bottom(~isnan(Bottom)));
        
        layer.Transceivers(uu).Bottom=bottom_cl('Origin','Algo_v2_bp',...
            'Range', bottom_range,...
            'Sample_idx',Bottom,...
            'Double_bot_mask',Double_bottom_region,'Tag',idx_noise_sector==0);
        
    end
    if uu==idx_38
        if reprocess==1
            
            layer.Transceivers(uu).rm_region_name('School');
            if own==0
            linked_candidates=feval(layer.Transceivers(uu).Algo(idx_school_detect).Function,layer.Transceivers(uu),...
                'Type','svdenoised',...
                'Sv_thr',-70,...
                'l_min_can',25,...
                'h_min_tot',10,...
                'h_min_can',5,...
                'l_min_tot',25,...
                'nb_min_sples',100,...
                'horz_link_max',55,...
                'vert_link_max',5);
            else
                 linked_candidates=feval(layer.Transceivers(uu).Algo(idx_school_detect).Function,layer.Transceivers(uu),...
                'Type','svdenoised',...
                'Sv_thr',layer.Transceivers(uu).Algo(idx_school_detect).Varargin.Sv_thr,...
                'l_min_can',layer.Transceivers(uu).Algo(idx_school_detect).Varargin.l_min_can,...
                'h_min_tot',layer.Transceivers(uu).Algo(idx_school_detect).Varargin.h_min_tot,...
                'h_min_can',layer.Transceivers(uu).Algo(idx_school_detect).Varargin.h_min_tot,...
                'l_min_tot',layer.Transceivers(uu).Algo(idx_school_detect).Varargin.l_min_tot,...
                'nb_min_sples',layer.Transceivers(uu).Algo(idx_school_detect).Varargin.nb_min_sples,...
                'horz_link_max',layer.Transceivers(uu).Algo(idx_school_detect).Varargin.horz_link_max,...
                'vert_link_max',layer.Transceivers(uu).Algo(idx_school_detect).Varargin.vert_link_max);
            end
            
            layer.Transceivers(uu).create_regions_from_linked_candidates(linked_candidates,'w_unit','pings','h_unit','meters','cell_w',5,'cell_h',5);
        end
    end
end

end