
function data=computesPhasesAngles_v2(trans_obj,data)

for idx_freq=1:length(trans_obj)
    angleSensitivityAlongship=trans_obj(idx_freq).Config.AngleSensitivityAlongship;
    angleSensitivityAthwartship=trans_obj(idx_freq).Config.AngleSensitivityAthwartship;
    switch trans_obj(idx_freq).Config.TransceiverType
        case {'WBT','WBT Tube','WBAT'}
            switch trans_obj(idx_freq).Config.TransducerName
                case {'ES38-7' 'ES333'}
                    
                    sa=data.pings(idx_freq).comp_sig_1;
                    pa=data.pings(idx_freq).comp_sig_2;
                    fo=data.pings(idx_freq).comp_sig_3;
                    ce=data.pings(idx_freq).comp_sig_4;
                    
                    sec1=real(sa)+real(ce)+1j*imag(sa+ce);
                    sec2=real(pa)+real(ce)+1j*imag(pa+ce);
                    sec3=real(fo)+real(ce)+1j*imag(fo+ce);
                    
                    phi31=angle(sec3.*conj(sec1))/pi*180;
                    phi32=angle(sec3.*conj(sec2))/pi*180;
                    
                    data.pings(idx_freq).AlongPhi=1/sqrt(3)*(phi31+phi32);
                    data.pings(idx_freq).AcrossPhi=(phi32-phi31);
                    k_angle=1; 
                    
                otherwise
                    
                    
                    s1=data.pings(idx_freq).comp_sig_1;
                    s2=data.pings(idx_freq).comp_sig_2;
                    s3=data.pings(idx_freq).comp_sig_3;
                    s4=data.pings(idx_freq).comp_sig_4;
                    
                    fore=(s3+s4)/2;
                    aft =(s2+s1)/2;
                    stbd =(s1+s4)/2;
                    port =(s3+s2)/2;
                    
                    k_angle=1;
                    
                    data.pings(idx_freq).AlongPhi=angle(fore.*conj(aft))/pi*180;
                    data.pings(idx_freq).AcrossPhi=angle((stbd).*conj(port))/pi*180;
                    
            end
            
        case {'GPT' 'ER60' 'ES60' 'ES70'}
            k_angle=180/127;
        otherwise
            k_angle=180/127;
    end
    
    data.pings(idx_freq).AlongAngle=(data.pings(idx_freq).AlongPhi)*k_angle/angleSensitivityAlongship-trans_obj(idx_freq).Config.AngleOffsetAthwartship;
    data.pings(idx_freq).AcrossAngle=(data.pings(idx_freq).AcrossPhi)*k_angle/angleSensitivityAthwartship-trans_obj(idx_freq).Config.AngleOffsetAthwartship;
    
end

switch trans_obj(idx_freq).Config.TransceiverType
    case {'WBT','WBT Tube','WBAT'}
        data.pings=rmfield(data.pings,{'comp_sig_1','comp_sig_2','comp_sig_3','comp_sig_4','AlongPhi','AcrossPhi'});
    otherwise
        data.pings=rmfield(data.pings,{'AlongPhi','AcrossPhi'});
end
end
