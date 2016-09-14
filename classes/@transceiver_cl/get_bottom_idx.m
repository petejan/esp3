function bot_idx=get_bottom_idx(trans_obj,varargin)

nb_pings=length(trans_obj.Data.get_numbers());

Bottom_idx=trans_obj.Bottom.Sample_idx;
if isempty(Bottom_idx)
    bot_idx=ones(1,nb_pings);
else
    bot_idx=nan(size(Bottom_idx));
    bot_idx(~isnan(Bottom_idx))=Bottom_idx(~isnan(Bottom_idx));
end
bot_idx=bot_idx(:)';

if ~isempty(varargin)
    bot_idx=bot_idx(varargin{1});
end
    