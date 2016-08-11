function [perc,nb_pings] = get_badtrans_perc(trans_obj,varargin)

p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
parse(p,trans_obj,varargin{:});

nb_pings=length(trans_obj.Bottom.Tag);
perc=nansum(trans_obj.Bottom.Tag==0)/nb_pings*100;


end