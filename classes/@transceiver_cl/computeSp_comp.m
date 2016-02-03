function computeSp_comp(trans_obj)

BW_athwart=trans_obj.Config.BeamWidthAthwartship;
BW_along=trans_obj.Config.BeamWidthAlongship;
[sp,~]=get_datamat(trans_obj.Data,'sp');
along=trans_obj.Data.get_datamat('AlongAngle');
athwart=trans_obj.Data.get_datamat('AcrossAngle');
switch trans_obj.Mode
    case 'FM'
        
    case 'CW'

        trans_obj.Data.remove_sub_data('sp_comp');
        trans_obj.Data.add_sub_data(sub_ac_data_cl('sp_comp',trans_obj.Data.MemapName,sp+...
            6.0206 * ((2*along/BW_along).^2 + (2*athwart/BW_athwart).^2 - 0.18*(2*along/BW_along).^2.*(2*athwart/BW_athwart).^2)));
end


end