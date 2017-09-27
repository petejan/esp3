function computeSpSv(trans_obj,env_data_obj,varargin)


p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'env_data_obj',@(obj) isa(obj,'env_data_cl'));
addParameter(p,'FieldNames',{},@iscell);


parse(p,trans_obj,env_data_obj,varargin{:});

f = trans_obj.Config.Frequency;
c = env_data_obj.SoundSpeed;

alpha = trans_obj.Params.Absorption(1);
cal=trans_obj.get_cal();
G=cal.G0;
eq_beam_angle = trans_obj.Config.EquivalentBeamAngle;
ptx = trans_obj.Params.TransmitPower;
[t_eff,~]=get_pulse_Teff(trans_obj);
[t_nom,~]=get_pulse_length(trans_obj);
sacorr = cal.SACORRECT;

range=trans_obj.get_transceiver_range();
[power,~]=get_datamat(trans_obj.Data,'power');
[powerunmatched,~]=get_datamat(trans_obj.Data,'powerunmatched');

gpu_comp=gpuDeviceCount>0&& license('test','Distrib_Computing_Toolbox');


if gpu_comp%use of gpuArray results in about 20% speed increase here
    power=gpuArray(power);
    range=gpuArray(range);
    powerunmatched=gpuArray(powerunmatched);
    ptx=gpuArray(ptx);
end

switch trans_obj.Mode
    case 'FM'
        
        [Sp,Sv]=convert_power(power,range,c,alpha,t_eff,t_nom,ptx,c/f,G,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);
        
        if any(strcmpi(p.Results.FieldNames,'sp'))||isempty(p.Results.FieldNames)
            [Sp_un,~]=convert_power(powerunmatched,range,c,alpha,t_eff,t_nom,ptx,c/f,G,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);
            if gpu_comp
                Sp_un=gather(Sp_un);
            end
            trans_obj.Data.replace_sub_data('spunmatched',Sp_un);
        end
        
        
    case 'CW'
        
        switch trans_obj.Config.TransceiverType
            case list_WBTs()
                [Sp,Sv]=convert_power(power,range,c,alpha,t_eff,t_nom,ptx,c/f,G,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);
            otherwise
                [Sp,Sv]=convert_power(power,range,c,alpha,t_nom,t_nom,ptx,c/f,G,eq_beam_angle,sacorr,trans_obj.Config.TransceiverName);
        end
        
end



if any(strcmpi(p.Results.FieldNames,'sv'))||isempty(p.Results.FieldNames)
    if gpu_comp
        Sv=gather(Sv);
    end
    
    trans_obj.Data.replace_sub_data('sv',Sv);
end
if any(strcmpi(p.Results.FieldNames,'sp'))||isempty(p.Results.FieldNames)
    if gpu_comp
        Sp=gather(Sp);
    end
    trans_obj.Data.replace_sub_data('sp',Sp);
end


end