function [type,radius]=get_start_type_and_radius(surv_in_obj,snap_num,strat_name)

snap_numbers=[surv_in_obj.Snapshots{:}.Number];

idx_snap=find(snap_numbers==snap_num);

type='';
radius=0;

for i=1:length(idx_snap)
    strats=surv_in_obj.Snapshots{idx_snap(i)}.Stratum;  
    strat_names=[strats{:}.Name];
    idx_strat=find(strcmpi(strat_name,strat_names),1);
    
    if~isempty(idx_strat)
        type=strats{idx_strat}.Type;
        radius=strats{idx_strat}.Radius;
    end
end

if isempty(type)
    type='';
end

if isempty(radius)
    radius=0;
end

end