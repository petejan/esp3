function computeAngles(obj)

AcrossPhi=obj.Data.get_datamat('acrossphi');
AlongPhi=obj.Data.get_datamat('alongphi');

AlongAngle=obj.Data.get_datamat('alongangle');
AcrossAngle=obj.Data.get_datamat('acrossangle');


if contains(obj.Config.TransceiverName,{'ES60' 'ER60' 'ES70' 'GPT'})
    if isempty(AlongAngle)
        obj.Data.replace_sub_data('alongangle',AcrossPhi*180/127/obj.Config.AngleSensitivityAthwartship-obj.Config.AngleOffsetAthwartship);
    end
    if isempty(AcrossAngle)
        obj.Data.replace_sub_data('acrossangle',AlongPhi*180/127/obj.Config.AngleSensitivityAlongship-obj.Config.AngleOffsetAlongship);
    end
else
    if isempty(AlongAngle)
        obj.Data.replace_sub_data('alongangle',AcrossPhi/obj.Config.AngleSensitivityAthwartship-obj.Config.AngleOffsetAthwartship);
    end
    if isempty(AcrossAngle)
        obj.Data.replace_sub_data('acrossangle',AlongPhi/obj.Config.AngleSensitivityAlongship-obj.Config.AngleOffsetAlongship);
    end
end

obj.Data.remove_sub_data('acrossphi');
obj.Data.remove_sub_data('alongphi');


