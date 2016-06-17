    function theta=get_transmit_angle(TransAlongAngle,TransAcrossAngle,Pitch,Roll)

theta=atand(sqrt(tand(TransAcrossAngle-Roll).^2+tand(TransAlongAngle-Pitch).^2));
                
end