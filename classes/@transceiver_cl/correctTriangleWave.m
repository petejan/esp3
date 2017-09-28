function correctTriangleWave(trans_obj,varargin)

p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addParameter(p,'EsOffset',[]);

parse(p,trans_obj,varargin{:});

[power,~]=get_datamat(trans_obj.Data,'power');

[power_corr_db,mean_err]=correctES60(10*log10(power),p.Results.EsOffset);

if mean_err~=0
    trans_obj.Data.replace_sub_data('power',10.^(power_corr_db/10));
    trans_obj.Config.EsOffset=mean_err;
end

end