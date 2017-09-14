function str_perbp = bp_percent2str(trans_obj)

val=nansum(trans_obj.Bottom.Tag==0)/numel(trans_obj.Bottom.Tag==0)*100;

str_perbp=[ sprintf('Bad transmits: %.1f',val) '%'];

end

