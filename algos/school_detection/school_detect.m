%% school_detect.m
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
% * |trans_obj|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |linked_candidates|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function linked_candidates = school_detect(trans_obj,varargin)

p = inputParser;

check_trans_class=@(obj) isa(obj,'transceiver_cl');

default_Sv_thr=-70;
check_Sv_thr=@(thr)(thr>=-120&&thr<=-30);

default_Sv_max=default_Sv_thr+36;
check_Sv_max=@(thr)(thr>=-70&&thr<=0);

default_l_min_can=15;
check_l_min_can=@(l)(l>=0&&l<=500);

default_h_min_can=5;
check_h_min_can=@(l)(l>=0&&l<=100);

default_l_min_tot=25;
check_l_min_tot=@(l)(l>=0);

default_h_min_tot=10;
check_h_min_tot=@(l)(l>=0);

default_horz_link_max=55;
check_horz_link_max=@(l)(l>=0&&l<=500);

default_vert_link_max=5;
check_vert_link_max=@(l)(l>=0&&l<=100);

default_nb_min_sples=100;
check_nb_min_sples=@(l)(l>0);


addRequired(p,'trans_obj',check_trans_class);
addParameter(p,'Type','sv',@ischar);
addParameter(p,'Sv_thr',default_Sv_thr,check_Sv_thr);
addParameter(p,'Sv_max',default_Sv_max,check_Sv_max);%only affect display
addParameter(p,'l_min_can',default_l_min_can,check_l_min_can);
addParameter(p,'h_min_can',default_h_min_can,check_h_min_can);
addParameter(p,'l_min_tot',default_l_min_tot,check_l_min_tot);
addParameter(p,'h_min_tot',default_h_min_tot,check_h_min_tot);
addParameter(p,'horz_link_max',default_horz_link_max,check_horz_link_max);
addParameter(p,'vert_link_max',default_vert_link_max,check_vert_link_max);
addParameter(p,'nb_min_sples',default_nb_min_sples,check_nb_min_sples);
addParameter(p,'idx_r',1:length(trans_obj.get_transceiver_range()),@isnumeric);
addParameter(p,'idx_pings',1:length(trans_obj.get_transceiver_pings()),@isnumeric);
addParameter(p,'depth_max',15000,@isnumeric);
addParameter(p,'load_bar_comp',[]);

parse(p,trans_obj,varargin{:});

if isempty(p.Results.idx_r)
    idx_r=1:numel(trans_obj.get_transceiver_range());
else
    idx_r=p.Results.idx_r;
end

if isempty(p.Results.idx_pings)
    idx_pings=1:numel(trans_obj.get_transceiver_pings());
else
    idx_pings=p.Results.idx_pings;
end

Sv_mat=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field',p.Results.Type);
if isempty(Sv_mat)
   Sv_mat=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field',p.Results.Type);
end

range=trans_obj.get_transceiver_range(idx_r);
dist=trans_obj.GPSDataPing.Dist;

if nanmean(diff(dist))>0
    dist_pings=dist(idx_pings);
else
    warning('No Distance was computed, using ping instead of distance for school detection');
    dist_pings=trans_obj.get_transceiver_pings(idx_pings)';
end



Bottom=trans_obj.get_bottom_range(idx_pings);

[~,Np]=trans_obj.get_pulse_Teff();
Sv_thr=p.Results.Sv_thr;
l_min_can=p.Results.l_min_can;
h_min_can=p.Results.h_min_can;
l_min_tot=p.Results.l_min_tot;
h_min_tot=p.Results.h_min_tot;
horz_link_max=p.Results.horz_link_max;
vert_link_max=p.Results.vert_link_max;
nb_min_sples=p.Results.nb_min_sples;
% 

% alpha_map=double(Sv_mat>=Sv_thr);

[nb_samples,~]=size(Sv_mat);
mask=zeros(size(Sv_mat));
idx_bad=(trans_obj.Bottom.Tag(idx_pings)==0);

idx_bad_data=trans_obj.find_regions_type('Bad Data');

for jj=1:length(idx_bad_data)
   curr_reg=trans_obj.Regions(idx_bad_data(jj));
   mask(curr_reg.Idx_r-idx_r(1)+1,curr_reg.Idx_pings-idx_pings(1)+1)=mask(curr_reg.Idx_r-idx_r(1)+1,curr_reg.Idx_pings-idx_pings(1)+1)+curr_reg.create_mask();
end
mask(:,idx_bad)=1;

if nansum(~isnan(Bottom))==0
    Sv_mask_ori=double(bsxfun(@and,Sv_mat>=Sv_thr&(mask<1),(1:nb_samples)'>3*Np));
else
    Bottom(isnan(Bottom))=nb_samples;
    Sv_mask_ori=double(bsxfun(@and,Sv_mat>=Sv_thr&(mask<1),(1:nb_samples)'>3*Np)&(bsxfun(@lt,range,Bottom)));
end

Sv_mask_ori(range>=p.Results.depth_max,:)=0;
    


Sv_mask=double((filter2(ones(3,3),Sv_mask_ori,'same'))>1);
%Sv_mask=Sv_mask_ori;
% h_filter=2*Np;
% Sv_mask=floor(filter2(ones(h_filter,1)/h_filter,double(Sv_mask>0),'same'));
% Sv_mask=ceil(filter2(ones(h_filter,1)/h_filter,Sv_mask,'same'));
% 



candidates=find_candidates_v3(Sv_mask,range,dist_pings,l_min_can,h_min_can,nb_min_sples,'mat',p.Results.load_bar_comp);
linked_candidates_mini=link_candidates_v2(candidates,dist_pings,range,horz_link_max,vert_link_max,l_min_tot,h_min_tot,p.Results.load_bar_comp);

linked_candidates=zeros(numel(trans_obj.get_transceiver_range()),numel(trans_obj.get_transceiver_pings()));

linked_candidates(idx_r,idx_pings)=linked_candidates_mini;



end