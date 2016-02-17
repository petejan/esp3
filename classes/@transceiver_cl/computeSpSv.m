function computeSpSv(trans_obj,env_data_obj)

f = trans_obj.Config.Frequency(1);
c = env_data_obj.SoundSpeed;
t = trans_obj.Params.SampleInterval(1);
alpha = trans_obj.Params.Absorbtion;
cal=get_cal(trans_obj);
G=cal.G0;
eq_beam_angle = trans_obj.Config.EquivalentBeamAngle;
ptx = trans_obj.Params.TransmitPower(1);
[t_eff,~]=get_pulse_Comp_length(trans_obj);
[t_eff_cw,~]=get_pulse_length(trans_obj);
sacorr = cal.SACORRECT;

dR = double(c * t / 2);
[power,~]=get_datamat(trans_obj.Data,'power');
[powerunmatched,~]=get_datamat(trans_obj.Data,'powerunmatched');

switch trans_obj.Mode
    case 'FM'
        range = double((trans_obj.Data.Samples - 1) * dR);
        
        [Sp,Sv]=convert_power(power,range,c,alpha,t_eff,ptx,c/f,G,eq_beam_angle,sacorr);
        [Sp_un,~]=convert_power(powerunmatched,range,c,alpha,t_eff_cw,ptx,c/f,G,eq_beam_angle,sacorr);
        

        trans_obj.Data.Range=range;        
        trans_obj.Data.add_sub_data('sv',Sv);
        trans_obj.Data.add_sub_data('sp',Sp);
        trans_obj.Data.add_sub_data('spunmatched',Sp_un);
    case 'CW'
        range = double((trans_obj.Data.Samples - 1) * dR);
        
        [Sp,Sv]=convert_power(power,range,c,alpha,t_eff,ptx,c/f,G,eq_beam_angle,sacorr);
       
        trans_obj.Data.Range=range;
        trans_obj.Data.add_sub_data('sv',Sv);
        trans_obj.Data.add_sub_data('sp',Sp);
end




end