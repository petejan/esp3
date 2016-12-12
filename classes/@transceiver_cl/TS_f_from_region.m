function TS_f_from_region(trans_obj,reg_obj,varargin)

p = inputParser;
addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addRequired(p,'reg_obj',@(x) isa(x,'region_cl'));
addParameter(p,'env_obj',env_data_cl,@(x) isa(x,'env_data_cl'));
addParameter(p,'cal',[],@(x) isempty(x)||isstruct);


parse(p,trans_obj,reg_obj,varargin{:});



end