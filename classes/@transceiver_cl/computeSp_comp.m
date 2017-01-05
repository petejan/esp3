function computeSp_comp(trans_obj)

BW_athwart=trans_obj.Config.BeamWidthAthwartship;
BW_along=trans_obj.Config.BeamWidthAlongship;
[sp,~]=get_datamat(trans_obj.Data,'sp');
along=trans_obj.Data.get_datamat('AlongAngle');
athwart=trans_obj.Data.get_datamat('AcrossAngle');
switch trans_obj.Mode
    case 'FM'
        
    case 'CW'
        trans_obj.Data.replace_sub_data('sp_comp',sp+...
            6.0206 * ((2*along/BW_along).^2 + (2*athwart/BW_athwart).^2 - 0.18*(2*along/BW_along).^2.*(2*athwart/BW_athwart).^2));
end


end