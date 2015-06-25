function [x_along,y_across,z]=angles_to_pos(Range,AlongAngle,AcrossAngle,Heave,Pitch,Roll)

theta=atand(sqrt(tand(AcrossAngle-Roll).^2+tand(AlongAngle-Pitch).^2));
z = Range.*cosd(theta)-Heave;

x_along = z.*tand(AlongAngle+Pitch);
y_across = z.*tand(AcrossAngle+Roll);

                
end