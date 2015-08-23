function [x_along,y_across,z]=angles_to_pos(Range,AlongAngle,AcrossAngle,Heave,Pitch,Roll)

% x_along = Range.*sind(AcrossAngle-Roll).*sind(AlongAngle-Pitch);
% y_across = Range.*cosd(AlongAngle-Pitch).*sind(AcrossAngle-Roll);
% z =-Range.*cosd(AlongAngle-Pitch).*cosd(AcrossAngle-Roll)-Heave;

theta=atand(sqrt(tand(AcrossAngle-Roll).^2+tand(AlongAngle-Pitch).^2));
z = Range.*cosd(theta)-Heave;
x_along = z.*tand(AlongAngle+Pitch);
y_across = z.*tand(AcrossAngle+Roll);

                
end