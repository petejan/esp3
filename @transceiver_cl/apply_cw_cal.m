function apply_cw_cal(Transceiver,new_cal)
 old_cal=Transceiver.get_cal();
 Transceiver.set_cal(struct('Gain',new_cal.Gain,'SaCorr',new_cal.SaCorr));
Sv=Transceiver.Data.get_datamat('sv');
Sp=Transceiver.Data.get_datamat('sp');

Sv_new=Sv+2*(old_cal.SaCorr-new_cal.SaCorr)+2*(old_cal.Gain-new_cal.Gain);
Sp_new=Sp+2*(old_cal.Gain-new_cal.Gain);


name=Transceiver.Data.MemapName;
Transceiver.Data.remove_sub_data('sv');
Transceiver.Data.remove_sub_data('sp');

Transceiver.Data.add_sub_data(sub_ac_data_cl('sv',name,Sv_new));
Transceiver.Data.add_sub_data(sub_ac_data_cl('sp',name,Sp_new));


end