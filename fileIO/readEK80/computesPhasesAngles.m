
function data=computesPhasesAngles(data)


for idx_freq=1:length(data.config)
    
    
    angleSensitivityAlongship=data.config(idx_freq).AngleSensitivityAlongship;
    angleSensitivityAthwartship=data.config(idx_freq).AngleSensitivityAthwartship;
    
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
    data.pings(idx_freq).AlongAngle=(data.pings(idx_freq).AlongPhi)*k_angle/angleSensitivityAlongship;
    data.pings(idx_freq).AcrossAngle=(data.pings(idx_freq).AcrossPhi)*k_angle/angleSensitivityAthwartship;
    
end
data.pings=rmfield(data.pings,{'comp_sig_1','comp_sig_2','comp_sig_3','comp_sig_4'});