
function add_algo(trans_obj,algo_obj,varargin)
%names={'BottomDetection','BadPings','Denoise','SchoolDetection','SingleTarget','TrackTarget'};

p = inputParser;

addRequired(p,'trans_obj',@(obj) isa(obj,'transceiver_cl'));
addRequired(p,'algo_obj',@(obj) isa(algo_obj,'algo_cl'));

parse(p,trans_obj,algo_obj,varargin{:});

for ial=1:length(algo_obj)
    nb_algos=length(trans_obj.Algo);
    [idx_alg,alg_found]=find_algo_idx(trans_obj,algo_obj(ial).Name);
    if alg_found==0
        trans_obj.Algo(nb_algos+1)=algo_obj(ial);
    else
        trans_obj.Algo(idx_alg)=algo_obj(ial);
    end 
end