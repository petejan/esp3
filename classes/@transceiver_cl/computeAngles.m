function computeAngles(obj)

AlongPhi=obj.Data.get_datamat('acrossphi');
AcrossPhi=obj.Data.get_datamat('alongphi');


if ~isempty(strfind(obj.Config.TransceiverName,'ES60'))||~isempty(strfind(obj.Config.TransceiverName,'ES70'))||~isempty(strfind(obj.Config.TransceiverName,'ER60'))
    obj.Data.add_sub_data(sub_ac_data_cl('alongangle',obj.Data.MemapName,AcrossPhi*180/127/obj.Config.AngleSensitivityAthwartship-obj.Config.AngleOffsetAthwartship));
    obj.Data.add_sub_data(sub_ac_data_cl('acrossangle',obj.Data.MemapName,AlongPhi*180/127/obj.Config.AngleSensitivityAlongship-obj.Config.AngleOffsetAlongship));
else
    obj.Data.add_sub_data(sub_ac_data_cl('alongangle',obj.Data.MemapName,AcrossPhi/obj.Config.AngleSensitivityAthwartship-obj.Config.AngleOffsetAthwartship));
    obj.Data.add_sub_data(sub_ac_data_cl('acrossangle',obj.Data.MemapName,AlongPhi/obj.Config.AngleSensitivityAlongship-obj.Config.AngleOffsetAlongship));
end
obj.Data.remove_sub_data('acrossphi');
obj.Data.remove_sub_data('alongphi');


