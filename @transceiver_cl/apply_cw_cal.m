function apply_cw_cal(Transceiver,new_cal)
 old_cal=Transceiver.get_cal();
 Transceiver.set_cal(struct('Gain',new_cal.Gain,'SaCorr',new_cal.SaCorr));
Sv=Transceiver.Data.get_datamat('Sv');
Sp=Transceiver.Data.get_datamat('Sp');
 
Transceiver.Data.MatfileData.Sv=Sv+2*(old_cal.SaCorr-new_cal.SaCorr)+2*(old_cal.Gain-new_cal.Gain);
Transceiver.Data.MatfileData.Sp=Sp+2*(old_cal.Gain-new_cal.Gain);

end