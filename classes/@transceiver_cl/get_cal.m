
function cal=get_cal(trans_obj)

    G0=trans_obj.get_current_gain();
    SACORRECT=trans_obj.get_current_sacorr();

    cal=struct('G0',G0,'SACORRECT',SACORRECT);   

end