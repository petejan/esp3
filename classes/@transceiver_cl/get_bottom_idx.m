function bot_idx=get_bottom_idx(trans_obj,varargin)

nb_pings=length(trans_obj.get_transceiver_pings());

Bottom_idx=trans_obj.Bottom.Sample_idx;
if isempty(Bottom_idx)
    bot_idx=ones(1,nb_pings);
else
    bot_idx=nan(1,nb_pings);
    bot_idx(~isnan(Bottom_idx))=Bottom_idx(~isnan(Bottom_idx));
end

bot_idx=bot_idx(:)';
bot_idx(bot_idx==0)=1;

if ~isempty(varargin)
    idx=varargin{1};
    idx(idx<=0|idx>numel(bot_idx))=[];
    bot_idx=bot_idx(idx);
end
    