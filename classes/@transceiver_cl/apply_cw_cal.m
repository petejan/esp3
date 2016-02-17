function apply_cw_cal(Transceiver,new_cal)
old_cal=Transceiver.get_cal();

Transceiver.set_cal(struct('G0',new_cal.G0,'SACORRECT',new_cal.SACORRECT));

Sv=Transceiver.Data.get_datamat('sv');

if ~isempty(Sv)
    Sv_new=Sv+2*(old_cal.SACORRECT-new_cal.SACORRECT)+2*(old_cal.G0-new_cal.G0);
    Transceiver.Data.add_sub_data('sv',Sv_new);
end

Sp=Transceiver.Data.get_datamat('sp');

if ~isempty(Sp)
    Sp_new=Sp+2*(old_cal.G0-new_cal.G0);

    Transceiver.Data.add_sub_data('sp',Sp_new);
end

end