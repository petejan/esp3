function idx_bad = get_badtrans_idx(trans_obj,varargin)

p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
parse(p,trans_obj,varargin{:});

idx_bad=find(trans_obj.Bottom.Tag==0);


end