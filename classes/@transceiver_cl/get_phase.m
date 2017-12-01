function [AlongPhi,AcrossPhi]=get_phase(trans_obj,varargin)

p = inputParser;

addRequired(p,'trans_obj',@(x) isa(trans_obj,'transceiver_cl'));
addParameter(p,'idx_r',[],@isnumeric);
addParameter(p,'idx_ping',[],@isnumeric);

parse(p,trans_obj,varargin{:});

AlongAngle=trans_obj.Data.get_subdatamat(p.Results.idx_r,p.Results.idx_ping,'field','alongangle');
AcrossAngle=trans_obj.Data.get_subdatamat(p.Results.idx_r,p.Results.idx_ping,'field','acrossangle');

if contains(trans_obj.Config.TransceiverName,{'ES60' 'ES70''ER60'})
    AcrossPhi=(AcrossAngle+trans_obj.Config.AngleOffsetAthwartship)*trans_obj.Config.AngleSensitivityAthwartship*127/180;
    AlongPhi=(AlongAngle+trans_obj.Config.AngleOffsetAlongship)*trans_obj.Config.AngleSensitivityAlongship*127/180;
else
    AcrossPhi=(AcrossAngle+trans_obj.Config.AngleOffsetAthwartship)*trans_obj.Config.AngleSensitivityAlongship;
    AlongPhi=(AlongAngle+trans_obj.Config.AngleOffsetAlongship)*trans_obj.Config.AngleSensitivityAthwartship;
end
