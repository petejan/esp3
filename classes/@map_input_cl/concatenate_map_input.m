function map_input_out=concatenate_map_input(map_input_vec)
p = inputParser;

addRequired(p,'obj',@(x) isa(x,'map_input_cl'));

parse(p,map_input_vec);


if isempty(map_input_vec)
    map_input_out=map_input_vec;
    return;
end

props=properties(map_input_cl);

map_input_out=map_input_vec(1);


for iv=2:length(map_input_vec)
    for ip=1:length(props)-7
        if iscell(map_input_vec(iv).(props{ip}))
            map_input_out.(props{ip})=[map_input_out.(props{ip}) map_input_vec(iv).(props{ip})];
        else
            map_input_out.(props{ip})=[map_input_out.(props{ip}) map_input_vec(iv).(props{ip})];
        end
    end
    map_input_out.LatLim(1)=nanmin([map_input_out.LatLim(1) map_input_vec(iv).LatLim(1)]);
    map_input_out.LatLim(2)=nanmax([map_input_out.LatLim(2) map_input_vec(iv).LatLim(2)]);
    map_input_out.LonLim(1)=nanmin([map_input_out.LonLim(1) map_input_vec(iv).LonLim(1)]);
    map_input_out.LonLim(2)=nanmax([map_input_out.LonLim(2) map_input_vec(iv).LonLim(2)]);
end

map_input_out.Proj=map_input_vec(1).Proj;
map_input_out.ValMax=map_input_vec(1).ValMax;
map_input_out.Rmax=map_input_vec(1).Rmax;
map_input_out.Coast=map_input_vec(1).Coast;
map_input_out.Depth_Contour=map_input_vec(1).Depth_Contour;

end