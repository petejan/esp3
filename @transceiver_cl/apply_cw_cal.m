function apply_cw_cal(Transceiver,new_cal)
 old_cal=Transceiver.get_cal();
 Transceiver.set_cal(struct('Gain',new_cal.Gain,'SaCorr',new_cal.SaCorr));

idx_sv=find_type_idx(Transceiver.Data,'Sv');
idx_sp=find_type_idx(Transceiver.Data,'Sp');
Transceiver.Data.SubData(idx_sv).DataMat=Transceiver.Data.SubData(idx_sv).DataMat+2*(old_cal.SaCorr-new_cal.SaCorr)+2*(old_cal.Gain-new_cal.Gain);
Transceiver.Data.SubData(idx_sp).DataMat=Transceiver.Data.SubData(idx_sp).DataMat+2*(old_cal.Gain-new_cal.Gain);

end