function linked_candidates=school_detect(Transceiver,varargin)

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


addRequired(p,'Transceiver',check_trans_class);
addParameter(p,'Type','Sv',@ischar);
addParameter(p,'Sv_thr',default_Sv_thr,check_Sv_thr);
addParameter(p,'Sv_max',default_Sv_max,check_Sv_max);%only affect display
addParameter(p,'l_min_can',default_l_min_can,check_l_min_can);
addParameter(p,'h_min_can',default_h_min_can,check_h_min_can);
addParameter(p,'l_min_tot',default_l_min_tot,check_l_min_tot);
addParameter(p,'h_min_tot',default_h_min_tot,check_h_min_tot);
addParameter(p,'horz_link_max',default_horz_link_max,check_horz_link_max);
addParameter(p,'vert_link_max',default_vert_link_max,check_vert_link_max);
addParameter(p,'nb_min_sples',default_nb_min_sples,check_nb_min_sples);


parse(p,Transceiver,varargin{:});


Sv_mat=Transceiver.Data.get_datamat('sv');

   
[nb_samples,nb_pings]=size(Sv_mat);
range=Transceiver.Data.Range;
dist_pings=Transceiver.GPSDataPing.Dist;

Bottom=Transceiver.Bottom.Range;
if isempty(Bottom)
    Bottom=ones(1,nb_pings)*range(end);
end

[~,Np]=get_pulse_length(Transceiver);
Sv_thr=p.Results.Sv_thr;
l_min_can=p.Results.l_min_can;
h_min_can=p.Results.h_min_can;
l_min_tot=p.Results.l_min_tot;
h_min_tot=p.Results.h_min_tot;
horz_link_max=p.Results.horz_link_max;
vert_link_max=p.Results.vert_link_max;
nb_min_sples=p.Results.nb_min_sples;

sample_mat=repmat((1:nb_samples)',1,nb_pings);
range_mat=repmat(range,1,nb_pings);
dist_pings_mat=repmat(dist_pings',nb_samples,1);
% 
% alpha_map=double(Sv_mat>=Sv_thr);

[nb_samples,nb_pings]=size(Sv_mat);
mask=zeros(size(Sv_mat));

idx_bad_data=Transceiver.list_regions_type('Bad Data');

for jj=1:length(idx_bad_data)
   curr_reg=Transceiver.Regions(idx_bad_data(jj));
   mask(curr_reg.Idx_r,curr_reg.Idx_pings)=mask(curr_reg.Idx_r,curr_reg.Idx_pings)+curr_reg.create_mask();
end


if nansum(~isnan(Bottom))==0
    Sv_mask_ori=double(Sv_mat>=Sv_thr&sample_mat>3*Np&(mask<1));
else
    Bottom(isnan(Bottom))=nb_samples;
    Sv_mask_ori=double(Sv_mat>=Sv_thr&range_mat<repmat(Bottom,nb_samples,1)&sample_mat>3*Np&(mask<1));
end

h_filter=2*Np;

Sv_mask=double((filter2(ones(3,3),Sv_mask_ori,'same'))>1);

Sv_mask=floor(filter2(ones(h_filter,1),double(Sv_mask>0),'same')./filter2(ones(h_filter,1),ones(size(Sv_mask)),'same'));
Sv_mask=ceil(filter2(ones(h_filter,1),Sv_mask,'same')./filter2(ones(h_filter,1),ones(size(Sv_mask)),'same'));


% figure()
% plot_mask=imagesc(dist_pings,range,Sv_mask);
% set(plot_mask,'alphadata',alpha_map);
% axis ij
% xlabel('Distance (m)')
% ylabel('Depth (m)')
% 
% tic
% regs_cleaned=find_candidates(sparse(Sv_mask),range_mat,dist_pings_mat,l_min_can,h_min_can,nb_min_sples);
% toc

regs_cleaned=find_candidates_v2(Sv_mask,range_mat,dist_pings_mat,l_min_can,h_min_can,nb_min_sples);


candidates=regs_cleaned;
%proceed with the linking
linked_candidates=link_candidates_v2(candidates,dist_pings_mat,range_mat,horz_link_max,vert_link_max,l_min_tot,h_min_tot);


% alpha_map_can=double(linked_candidates>0);


% figure()
% plot_sch=imagesc(dist_pings,range,linked_candidates);
% shading interp
% axis ij
% set(gcf,'ColorMap',jet)
% set(plot_sch,'alphadata',alpha_map_can);
% grid on;
% xlabel('Distance (m)')
% ylabel('Depth (m)')



end