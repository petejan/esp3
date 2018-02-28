function apply_cw_cal(trans_obj,new_cal)
old_cal=trans_obj.get_cal();
if isnan(new_cal.G0)
    new_cal.G0=old_cal.G0;
end
if isnan(new_cal.SACORRECT)
    new_cal.SACORRECT=old_cal.SACORRECT;
end

if old_cal.G0==new_cal.G0&&old_cal.SACORRECT==new_cal.SACORRECT
    return;
end
fprintf('   Old Calibration values: G0=%.2f dB SaCorr=%.2f dB\n',old_cal.G0,old_cal.SACORRECT);
fprintf('   New Calibration values: G0=%.2f dB SaCorr=%.2f dB\n',new_cal.G0,new_cal.SACORRECT);

if isnan(new_cal.G0)
    new_cal.G0=old_cal.G0;
end

trans_obj.set_cal(struct('G0',new_cal.G0,'SACORRECT',new_cal.SACORRECT));

diff_db_sv=2*(old_cal.SACORRECT-new_cal.SACORRECT)+2*(old_cal.G0-new_cal.G0);
trans_obj.Data.add_to_sub_data('sv',diff_db_sv)
diff_db_sp=2*(old_cal.G0-new_cal.G0);
trans_obj.Data.add_to_sub_data('sv',diff_db_sp)
end

