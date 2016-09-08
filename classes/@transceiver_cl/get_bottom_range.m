function bot_range=get_bottom_range(trans_obj,varargin)

range=trans_obj.Data.get_range();
nb_pings=length(trans_obj.Data.get_numbers());

Bottom_idx=trans_obj.Bottom.Sample_idx;
if isempty(Bottom_idx)
    bot_range=ones(1,nb_pings)*range(end);
else
    bot_range=range(Bottom_idx);
end

if ~isempty(varargin)
    bot_range=bot_range(varargin{1});
end
    