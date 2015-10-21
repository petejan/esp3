function [x_along,y_across,z]=angles_to_pos_v3(Range,AlongAngle,AcrossAngle,Heave,Pitch,Roll,AcrossAngleOff,AlongAngleOff,AcrossOffset,AlongOffset,Zoffset)

pos_mat=nan(3,length(Roll));

if length(Pitch)==1
    Pitch=Pitch*ones(size(Range));
    Roll=Roll*ones(size(Range));
    Heave=Heave*ones(size(Range));
end

for i=1:length(Pitch)
    along_corr=Pitch(i)+AlongAngleOff+AlongAngle(i);
    across_corr=Roll(i)+AcrossAngleOff+AcrossAngle(i);
    
    attitude_mat=create_attitude_matrix(along_corr,across_corr);
    attitude_mat_ori=create_attitude_matrix(Pitch(i),Roll(i));
    
    pos_mat(:,i)=attitude_mat*[0;0;Range(i)]+attitude_mat_ori*[AlongOffset;AcrossOffset;Zoffset]-[0;0;Heave(i)];
end


x_along=pos_mat(2,:);
y_across=pos_mat(1,:);
z=pos_mat(3,:);



                
end