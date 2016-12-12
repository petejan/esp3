function apply_cw_cal(trans_obj,new_cal)
old_cal=trans_obj.get_cal();

if old_cal.G0==new_cal.G0&&old_cal.SACORRECT==new_cal.SACORRECT
    return;
end

trans_obj.set_cal(struct('G0',new_cal.G0,'SACORRECT',new_cal.SACORRECT));

Sv=trans_obj.Data.get_datamat('sv');

if ~isempty(Sv)
    Sv_new=Sv+2*(old_cal.SACORRECT-new_cal.SACORRECT)+2*(old_cal.G0-new_cal.G0);
    trans_obj.Data.replace_sub_data('sv',Sv_new);
end

Sp=trans_obj.Data.get_datamat('sp');

if ~isempty(Sp)
    Sp_new=Sp+2*(old_cal.G0-new_cal.G0);
    trans_obj.Data.replace_sub_data('sp',Sp_new);
end

end