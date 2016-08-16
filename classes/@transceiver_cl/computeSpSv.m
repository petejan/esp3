function computeSpSv(trans_obj,env_data_obj,varargin)


p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'env_data_obj',@(obj) isa(obj,'env_data_cl'));
addParameter(p,'FieldNames',{},@iscell);


parse(p,trans_obj,env_data_obj,varargin{:});

f = trans_obj.Config.Frequency(1);
c = env_data_obj.SoundSpeed;

alpha = trans_obj.Params.Absorption(1);
cal=get_cal(trans_obj);
G=cal.G0;
eq_beam_angle = trans_obj.Config.EquivalentBeamAngle;
ptx = trans_obj.Params.TransmitPower(1);
[t_eff,~]=get_pulse_Comp_length(trans_obj);
[t_eff_cw,~]=get_pulse_length(trans_obj);
sacorr = cal.SACORRECT;

range=trans_obj.Data.get_range();
[power,~]=get_datamat(trans_obj.Data,'power');
[powerunmatched,~]=get_datamat(trans_obj.Data,'powerunmatched');

switch trans_obj.Mode
    case 'FM'

        [Sp,Sv]=convert_power(power,range,c,alpha,t_eff,ptx,c/f,G,eq_beam_angle,sacorr);
        
        trans_obj.Data.Range=[range(1) range(end)];

            if nansum(strcmpi(p.Results.FieldNames,'sp'))>0||isempty(p.Results.FieldNames)
                [Sp_un,~]=convert_power(powerunmatched,range,c,alpha,t_eff_cw,ptx,c/f,G,eq_beam_angle,sacorr);
                trans_obj.Data.add_sub_data('spunmatched',Sp_un);
            end

        
    case 'CW'

        [Sp,Sv]=convert_power(power,range,c,alpha,t_eff,ptx,c/f,G,eq_beam_angle,sacorr);
        
        trans_obj.Data.Range=[range(1) range(end)];
        
end

    if nansum(strcmpi(p.Results.FieldNames,'sv'))>0||isempty(p.Results.FieldNames)
        trans_obj.Data.add_sub_data('sv',Sv);
    end
    if nansum(strcmpi(p.Results.FieldNames,'sp'))>0||isempty(p.Results.FieldNames)
        trans_obj.Data.add_sub_data('sp',Sp);
    end


end