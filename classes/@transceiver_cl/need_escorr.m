function need=need_escorr(trans_obj)

need=strcmp(trans_obj.Config.TransceiverName(1:4),'ES70') | strcmp(trans_obj.Config.TransceiverName(1:4),'ES60');

end