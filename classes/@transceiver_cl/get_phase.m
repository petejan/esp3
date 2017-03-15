function [AlongPhi,AcrossPhi]=get_phase(obj)

AlongAngle=obj.Data.get_datamat('alongangle');
AcrossAngle=obj.Data.get_datamat('acrossangle');


if ~isempty(strfind(obj.Config.TransceiverName,'ES60'))||~isempty(strfind(obj.Config.TransceiverName,'ES70'))||~isempty(strfind(obj.Config.TransceiverName,'ER60'))
    AcrossPhi=(AcrossAngle+obj.Config.AngleOffsetAthwartship)*obj.Config.AngleSensitivityAthwartship*127/180;
    AlongPhi=(AlongAngle+obj.Config.AngleOffsetAlongship)*obj.Config.AngleSensitivityAlongship*127/180;
else
    AcrossPhi=(AcrossAngle+obj.Config.AngleOffsetAthwartship)*obj.Config.AngleSensitivityAlongship;
    AlongPhi=(AlongAngle+obj.Config.AngleOffsetAlongship)*obj.Config.AngleSensitivityAthwartship;
end
