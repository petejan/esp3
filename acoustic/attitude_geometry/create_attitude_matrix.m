function attitude_mat=create_attitude_matrix(Pitch,Roll)
pitch_mat=[[cosd(Pitch) sind(Pitch) 0];[ -sind(Pitch) cosd(Pitch) 0];[0 0 1]];
roll_mat=[[cosd(Roll) 0 sind(Roll)];[ 0 1 0 ];[-sind(Roll) 0 cosd(Roll)]];
attitude_mat=pitch_mat*roll_mat;
end