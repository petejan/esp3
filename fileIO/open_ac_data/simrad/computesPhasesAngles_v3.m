
function [AlongAngle,AcrossAngle]=computesPhasesAngles_v3(data_pings,angleSensitivityAlongship,angleSensitivityAthwartship,datatype,TransducerName,AngleOffsetAlongship,AngleOffsetAthwartship)

    if datatype(2)==dec2bin(1)
        k_angle=180/127;
    else
        k_angle=1;
        if datatype(1)==dec2bin(0)
            nb_chan=sum(contains(fieldnames(data_pings),'comp_sig'));                                
            switch TransducerName
                case {'ES38-7' 'ES333' }
                    switch TransducerName
                        case 'ES38-7'
                            
                            sa=data_pings.comp_sig_1;
                            pa=data_pings.comp_sig_2;
                            fo=data_pings.comp_sig_3;
                            ce=data_pings.comp_sig_4;
                            
                            sec1=sa+ce;
                            sec2=pa+ce;
                            sec3=fo+ce;
                            
                        case 'ES333'
                            sec1=data_pings.comp_sig_1;
                            sec2=data_pings.comp_sig_2;
                            sec3=data_pings.comp_sig_3;
                    end
                    
                    
                    
                    phi31=angle(sec3.*conj(sec1))/pi*180;
                    phi32=angle(sec3.*conj(sec2))/pi*180;
                    
                    data_pings.AlongPhi=1/sqrt(3)*(phi31+phi32);
                    data_pings.AcrossPhi=(phi32-phi31);                   
                    
                case 'ES38-18|200-18C'
                    if nb_chan==3
                        sec1=data_pings.comp_sig_1;
                        sec2=data_pings.comp_sig_2;
                        sec3=data_pings.comp_sig_3;
                        
                        phi31=angle(sec3.*conj(sec1))/pi*180;
                        phi32=angle(sec3.*conj(sec2))/pi*180;
                        data_pings.AlongPhi=1/sqrt(3)*(phi31+phi32);
                        data_pings.AcrossPhi=(phi32-phi31);
                        
                    else
                        data_pings.AlongPhi=zeros(size(data_pings.comp_sig_1));
                        data_pings.AcrossPhi=zeros(size(data_pings.comp_sig_1));                            
                    end
                otherwise
                    
                    s1=data_pings.comp_sig_1;
                    s2=data_pings.comp_sig_2;
                    s3=data_pings.comp_sig_3;
                    s4=data_pings.comp_sig_4;
                    
                    fore=(s3+s4)/2;
                    aft =(s2+s1)/2;
                    stbd =(s1+s4)/2;
                    port =(s3+s2)/2;
                    
                    data_pings.AlongPhi=angle(fore.*conj(aft))/pi*180;
                    data_pings.AcrossPhi=angle((stbd).*conj(port))/pi*180;
            end
        end
    end
    
    AlongAngle=(data_pings.AlongPhi)*k_angle/angleSensitivityAlongship-AngleOffsetAlongship;
    AcrossAngle=(data_pings.AcrossPhi)*k_angle/angleSensitivityAthwartship-AngleOffsetAthwartship;
    


end
