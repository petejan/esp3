function shift_bottom(trans_obj,r_shift)

Range=trans_obj.get_transceiver_range();
Bottom=trans_obj.Bottom;
bot_sample=Bottom.Sample_idx;
dr=nanmean(diff(Range));

Bottom.Sample_idx=bot_sample-round((r_shift-Bottom.Shifted)/dr);
Bottom.Shifted=r_shift;
trans_obj.setBottom(Bottom);

end