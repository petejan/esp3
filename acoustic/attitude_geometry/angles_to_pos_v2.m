function [x_along,y_across,z]=angles_to_pos_v2(Range,AlongAngle,AcrossAngle,Heave,Pitch,Roll)

theta=atand(sqrt(tand(AcrossAngle).^2+tand(AlongAngle).^2));
z_s = Range.*cosd(theta);
x_s = z_s.*tand(AlongAngle);
y_s = z_s.*tand(AcrossAngle);
pos_mat=nan(3,length(Roll));

if length(Pitch)>1
    for i=1:length(Pitch)
        pitch_mat=[[cosd(Pitch(i)) sind(Pitch(i)) 0];[ -sind(Pitch(i)) cosd(Pitch(i)) 0];[0 0 1]];
        roll_mat=[[cosd(Roll(i)) 0 sind(Roll(i))];[ 0 1 0 ];[-sind(Roll(i)) 0 cosd(Roll(i))]];    

        pos_mat(:,i)=pitch_mat*roll_mat*[y_s(i);x_s(i);z_s(i)];
    end   
else
    pitch_mat=[[cosd(Pitch) sind(Pitch) 0];[ -sind(Pitch) cosd(Pitch) 0];[0 0 1]];
    roll_mat=[[cosd(Roll) 0 sind(Roll)];[ 0 1 0 ];[-sind(Roll) 0 cosd(Roll)]];
    pos_mat=pitch_mat*roll_mat*[y_s;x_s;z_s]+pitch_mat*roll_mat*[y_trans;x_trans;z_trans];   
end

x_along=pos_mat(2,:);
y_across=pos_mat(1,:);
z=pos_mat(3,:)-Heave;



                
end