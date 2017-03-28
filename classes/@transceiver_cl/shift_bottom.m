function shift_bottom(trans_obj,r_shift,idx_p)

Range=trans_obj.get_transceiver_range();
Bottom=trans_obj.Bottom;
bot_sample=Bottom.Sample_idx;
dr=nanmean(diff(Range));
if isempty(idx_p)
    idx_p=1:numel(Bottom.Sample_idx);
end

Bottom.Sample_idx(idx_p)=bot_sample(idx_p)-round(r_shift/dr);
trans_obj.setBottom(Bottom);

end