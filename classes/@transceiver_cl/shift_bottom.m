%% shift_bottom.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |trans_obj|: TODO: write description and info on variable
% * |r_shift|: TODO: write description and info on variable
% * |idx_p|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
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