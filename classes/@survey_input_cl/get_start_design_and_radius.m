%% get_start_design_and_radius.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |surv_in_obj|: TODO: write description and info on variable
% * |snap_num|: TODO: write description and info on variable
% * |strat_name|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |type|: TODO: write description and info on variable
% * |radius|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-04-18: first version. slice weighting computation on hills on survey processing (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [design,radius] = get_start_design_and_radius(surv_in_obj,snap_num,strat_name)
nb_snap=length(surv_in_obj.Snapshots);
snap_numbers=nan(1,nb_snap);

for i=1:nb_snap
    snap_numbers(i)=[surv_in_obj.Snapshots{i}.Number];
end

idx_snap=find(snap_numbers==snap_num);

design='';
radius=0;

for i=1:length(idx_snap)
    strats=surv_in_obj.Snapshots{idx_snap(i)}.Stratum;
    nb_strat=numel(strats);
    
    strat_names=cell(1,nb_strat);
    
    for j=1:nb_strat
        strat_names{j}=[strats{j}.Name];
    end
    
    idx_strat=find(strcmpi(strat_name,strat_names),1);
    
    if~isempty(idx_strat)&&isfield(strats{idx_strat},'Design')
        design=strats{idx_strat}.Design;
        radius=strats{idx_strat}.Radius;
    end
end

if isempty(design)
    design='';
end

if isempty(radius)
    radius=0;
end

end