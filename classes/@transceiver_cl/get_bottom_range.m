function bot_range=get_bottom_range(trans_obj,varargin)

range=trans_obj.get_transceiver_range();
nb_pings=length(trans_obj.get_transceiver_pings());

Bottom_idx=trans_obj.Bottom.Sample_idx;
if isempty(Bottom_idx)
    bot_range=ones(1,nb_pings)*range(end);
else
    bot_range=nan(size(Bottom_idx));
    bot_range(~isnan(Bottom_idx))=range(Bottom_idx(~isnan(Bottom_idx)));
end
bot_range=bot_range(:)';

if ~isempty(varargin)
    bot_range=bot_range(varargin{1});
end
    