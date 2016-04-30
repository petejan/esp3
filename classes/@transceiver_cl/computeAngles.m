function computeAngles(obj)

AlongPhi=obj.Data.get_datamat('acrossphi');
AcrossPhi=obj.Data.get_datamat('alongphi');


if ~isempty(strfind(obj.Config.TransceiverName,'ES60'))||~isempty(strfind(obj.Config.TransceiverName,'ES70'))||~isempty(strfind(obj.Config.TransceiverName,'ER60'))||~isempty(strfind(obj.Config.TransceiverName,'GPT'))
    obj.Data.add_sub_data('alongangle',AcrossPhi*180/127/obj.Config.AngleSensitivityAthwartship-obj.Config.AngleOffsetAthwartship);
    obj.Data.add_sub_data('acrossangle',AlongPhi*180/127/obj.Config.AngleSensitivityAlongship-obj.Config.AngleOffsetAlongship);
else
    obj.Data.add_sub_data('alongangle',AcrossPhi/obj.Config.AngleSensitivityAthwartship-obj.Config.AngleOffsetAthwartship);
    obj.Data.add_sub_data('acrossangle',AlongPhi/obj.Config.AngleSensitivityAlongship-obj.Config.AngleOffsetAlongship);
end
obj.Data.remove_sub_data('acrossphi');
obj.Data.remove_sub_data('alongphi');


