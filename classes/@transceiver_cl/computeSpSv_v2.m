function computeSpSv_v2(trans_obj,env_data_obj,varargin)


p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'env_data_obj',@(obj) isa(obj,'env_data_cl'));
addParameter(p,'FieldNames',{},@iscell);
addParameter(p,'block_len',1e7,@(x) x>0);


parse(p,trans_obj,env_data_obj,varargin{:});

f = trans_obj.Config.Frequency;
c = env_data_obj.SoundSpeed;

alpha = trans_obj.Params.Absorption(1);
cal=trans_obj.get_cal();
G=cal.G0;
eq_beam_angle = trans_obj.Config.EquivalentBeamAngle;
ptx = trans_obj.Params.TransmitPower;
[t_eff,~]=trans_obj.get_pulse_Teff();
[t_nom,~]=trans_obj.get_pulse_length(1);
sacorr = cal.SACORRECT;

range=trans_obj.get_transceiver_range();
pings=trans_obj.get_transceiver_pings();

nb_samples=numel(range);
nb_pings=numel(pings);
gpu_comp=get_gpu_comp_stat();

bsize=ceil(p.Results.block_len/nb_samples);
u=0;
while u<ceil(nb_pings/bsize)
    idx_pings=(u*bsize+1):nanmin(((u+1)*bsize),nb_pings);
    u=u+1;
    
    pow=get_subdatamat(trans_obj.Data,1:nb_samples,idx_pings,'field','power');
    powunmatched=get_subdatamat(trans_obj.Data,1:nb_samples,idx_pings,'field','powerunmatched');
        
    if gpu_comp%use of gpuArray results in about 20% speed increase here
        %disp('GPU computation available')
        pow=gpuArray(pow);
        range=gpuArray(range);
        powunmatched=gpuArray(powunmatched);
        ptx=gpuArray(ptx);
    end
    
    switch trans_obj.Mode
        case 'FM'
            
            [Sp,Sv]=convert_power(pow,range,c,alpha,t_eff,t_nom,ptx(idx_pings),c/f,G,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);
            
            if any(strcmpi(p.Results.FieldNames,'sp'))||isempty(p.Results.FieldNames)
                [Sp_un,~]=convert_power(powunmatched,range,c,alpha,t_eff,t_nom,ptx(idx_pings),c/f,G,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);

                if gpu_comp
                    Sp_un=gather(Sp_un);
                end
                trans_obj.Data.replace_sub_data_v2('spunmatched',Sp_un,idx_pings,-999);
            end
            
            
        case 'CW'
            
            switch trans_obj.Config.TransceiverType
                case list_WBTs()
                    
                otherwise
                    t_eff=t_nom;
            end
            [Sp,Sv]=convert_power(pow,range,c,alpha,t_eff,t_nom,ptx(idx_pings),c/f,G,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);

    end
       
    if any(strcmpi(p.Results.FieldNames,'sv'))||isempty(p.Results.FieldNames)
        if gpu_comp
            Sv=gather(Sv);
        end       
        trans_obj.Data.replace_sub_data_v2('sv',Sv,idx_pings,-999);
        clear Sv;
    end
    if any(strcmpi(p.Results.FieldNames,'sp'))||isempty(p.Results.FieldNames)
        if gpu_comp
            Sp=gather(Sp);
        end
        trans_obj.Data.replace_sub_data_v2('sp',Sp,idx_pings,-999);
        clear Sp;
    end
    
end

end