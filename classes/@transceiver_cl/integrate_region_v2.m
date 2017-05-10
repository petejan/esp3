%Just a test function to see if we could work with Sarse matrices in the
%region integration process... Needs to be investigated but certainly
%promising and prettier code.
function output=integrate_region_v2(trans_obj,region,varargin)

p = inputParser;
addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addRequired(p,'region',@(x) isa(x,'region_cl'));
addParameter(p,'vertExtend',[0 Inf],@isnumeric);
addParameter(p,'horiExtend',[0 Inf],@isnumeric);
addParameter(p,'denoised',0,@isnumeric);
addParameter(p,'motion_correction',0,@isnumeric);
addParameter(p,'intersect_only',0,@isnumeric);
addParameter(p,'keep_bottom',0,@isnumeric);


parse(p,trans_obj,region,varargin{:});


% Sv=trans_obj.Data.get_datamat('svdenoised');
% if isempty(Sv)
%     Sv=trans_obj.Data.get_datamat('sv');
% end
idx_pings=region.Idx_pings;
idx_r=region.Idx_r;

if p.Results.denoised>0
    Sv_reg=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','svdenoised');
    if isempty(Sv_reg)
        disp('Cannot find denoised Sv, integrating normal Sv.')
        Sv_reg=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sv');
    end
else
    Sv_reg=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sv');
end

if p.Results.motion_correction>0
     motion_corr=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','motioncompensation');
     if ~isempty(motion_corr)
        Sv_reg=Sv_reg+motion_corr;  
     else
        disp('Cannot find motion corrected Sv, integrating normal Sv.') 
     end
end
%Sv_reg(Sv_reg<-80)=-999;


if isempty(Sv_reg)
    warning('No Sv, cannot integrate');
    output=[];
    return;
end

range=double(trans_obj.get_transceiver_range());
nb_samples=length(range);
samples=(1:nb_samples)';
dr=nanmean(diff(range));
pings=double(trans_obj.get_transceiver_pings());
%nb_pings=length(pings);
time=double(trans_obj.Time);

while nanmax(idx_pings)>length(pings)
    idx_pings=idx_pings-1;
end

idx_pings(idx_pings<=0)=[];

idx_r(idx_r>length(range))=[];

region.Idx_pings=idx_pings;
region.Idx_r=idx_r;

if isempty(idx_r)||isempty(idx_pings)
    warning('Cannot integrate this region, no data...');
    trans_obj.rm_region_id(region.Unique_ID);
    return;
end

dist=trans_obj.GPSDataPing.Dist;
lat=trans_obj.GPSDataPing.Lat;
lon=trans_obj.GPSDataPing.Long;

if isempty(dist)
    region.Cell_w_unit='pings';
    dist=nan(size(time));
    lat=nan(size(time));
    lon=nan(size(time));
end



if p.Results.intersect_only==1
    Sv_reg_save=Sv_reg;
    Sv_reg=nan(size(Sv_reg));
    idx=trans_obj.find_regions_type('Data');
    for i=idx
        curr_reg=trans_obj.Regions(i);
        if curr_reg.Unique_ID==region.Unique_ID
            continue;
        end
        
        idx_r_curr=curr_reg.Idx_r;
        idx_pings_curr=curr_reg.Idx_pings;
        [~,idx_r_from_reg,idx_r_from_curr]=intersect(idx_r,idx_r_curr);
        [~,idx_pings_from_reg,idx_pings_from_curr]=intersect(idx_pings,idx_pings_curr);
        switch curr_reg.Shape
            case 'Polygon'
                mask=curr_reg.MaskReg;
                Sv_temp=Sv_reg_save(idx_r_from_reg,idx_pings_from_reg);
                Sv_temp(mask(idx_r_from_curr,idx_pings_from_curr)==0)=NaN;
            otherwise
                Sv_temp=Sv_reg_save(idx_r_from_reg,idx_pings_from_reg);
        end
    
    Sv_reg(idx_r_from_reg,idx_pings_from_reg)= Sv_temp;
    end
end

idx=trans_obj.find_regions_type('Bad Data');
for i=idx
    curr_reg=trans_obj.Regions(i);
    if curr_reg.Unique_ID==region.Unique_ID
        continue;
    end
    
    idx_r_curr=curr_reg.Idx_r;
    idx_pings_curr=curr_reg.Idx_pings;
    [~,idx_r_from_reg,idx_r_from_curr]=intersect(idx_r,idx_r_curr);
    [~,idx_pings_from_reg,idx_pings_from_curr]=intersect(idx_pings,idx_pings_curr);
    
    switch curr_reg.Shape
        case 'Polygon'
            mask=curr_reg.MaskReg;
            Sv_temp=Sv_reg(idx_r_from_reg,idx_pings_from_reg);
            Sv_temp(mask(idx_r_from_curr,idx_pings_from_curr)>0)=NaN;
        otherwise
            Sv_temp=nan(length(idx_r_from_reg),length(idx_pings_from_reg));
    end
    Sv_reg(idx_r_from_reg,idx_pings_from_reg)= Sv_temp;
    
end


   




IdxBad=find(trans_obj.Bottom.Tag==0);
%IdxGood=find(trans_obj.Bottom.Tag>0);
bot_sple=trans_obj.Bottom.Sample_idx;
bot_sple(bot_sple==0)=1;


if region.Remove_ST
    mask_st=trans_obj.mask_from_st();
    Sv_reg(mask_st(idx_r,idx_pings))=NaN;
end

IdxBad_reg=intersect(IdxBad,idx_pings);
%IdxGood_reg=intersect(IdxGood,idx_pings);
Sv_reg(:,IdxBad_reg-idx_pings(1)+1)=NaN;
if isempty(bot_sple)
    bot_sple=ones(size(pings))*samples(end);
end

bot_r=nan(size(bot_sple));
bot_r(~isnan(bot_sple))=range(bot_sple(~isnan(bot_sple)));
bot_r(isnan(bot_sple))=nan;

bot_r(isnan(bot_r))=inf;
bot_sple(isnan(bot_sple))=inf;



switch region.Shape
    case 'Polygon'
        mask=region.MaskReg;
        Sv_reg(mask==0)=NaN; 
end


Mask=~isnan(Sv_reg);

sub_samples=samples(idx_r);
sub_pings=pings(idx_pings);
sub_r=range(idx_r);
sub_dist=dist(idx_pings)';
sub_time=time(idx_pings);
sub_lat=lat(idx_pings);
sub_lon=lon(idx_pings);
sub_bot_r=bot_r(idx_pings);
sub_bot_sple=bot_sple(idx_pings);

switch region.Cell_h_unit
    case 'samples'
        y=sub_samples;
        bot_int=sub_bot_sple;
    case 'meters'
        y=sub_r;
        bot_int=sub_bot_r;
end

switch region.Cell_w_unit
    case 'pings'
        x=sub_pings;
    case 'meters'
        x=sub_dist;
end


[x_mat,y_mat]=meshgrid(x,y);
[~,sub_r_mat]=meshgrid(sub_bot_r,sub_r);
[~,sub_samples_mat]=meshgrid(sub_bot_r,sub_samples);

switch region.Reference
    case 'Surface'
        line_ref=zeros(size(x));
    case 'Bottom'
        line_ref=bot_int;
        Mask(:,(bot_int==inf))=0;
    case 'Line'
        line_ref=zeros(size(x));
end

[t_mat,~]=meshgrid(sub_time,sub_r);
[bot_mat,~]=meshgrid(bot_int,sub_r);
[line_mat,~]=meshgrid(line_ref,sub_r);


y_mat_ori=y_mat;
y_mat=y_mat-line_mat;

switch region.Reference
    case 'Bottom'
      idx_rem=(y_mat<=-p.Results.vertExtend(2)|y_mat>=-p.Results.vertExtend(1))|(t_mat>p.Results.horiExtend(2)|t_mat<p.Results.horiExtend(1));
    case 'Line'
      idx_rem=(y_mat<=p.Results.vertExtend(2)|y_mat>=p.Results.vertExtend(1))|(t_mat>p.Results.horiExtend(2)|t_mat<p.Results.horiExtend(1));
    otherwise
      idx_rem=(y_mat>=p.Results.vertExtend(2)|y_mat<=-p.Results.vertExtend(1))|(t_mat>p.Results.horiExtend(2)|t_mat<p.Results.horiExtend(1));
end

Mask(idx_rem)=0;

if~any(Mask(:))
    output=[];
    return;
end

cell_w=region.Cell_w;
cell_h=region.Cell_h;





Sv_reg_lin=10.^(Sv_reg/10);


Mask_sparse=double(Mask);
if p.Results.keep_bottom==0
    Sv_reg_lin(y_mat_ori>=bot_mat)=0;
    Mask_sparse(y_mat_ori>=bot_mat)=0;
end

x_mat_idx=round((x_mat-cell_w/2)/cell_w);
y_mat_idx=round((y_mat-cell_h/2)/cell_h);

x_mat_idx=x_mat_idx-nanmin(x_mat_idx(:))+1;
y_mat_idx=y_mat_idx-nanmin(y_mat_idx(:))+1;

Sv_lin_sparse_temp = sparse(y_mat_idx,x_mat_idx,Sv_reg_lin);

nb_samples = sparse(y_mat_idx,x_mat_idx,Mask_sparse);

Sv_lin_sparse = full(Sv_lin_sparse_temp./nb_samples);


[N_y,N_x]=size(Sv_lin_sparse);
 

output.Sv_mean_lin_esp2=Sv_lin_sparse;
output.Sv_mean_lin=Sv_lin_sparse;


output.Sa_lin=zeros(N_y,N_x);

output.nb_samples=nan(N_y,N_x);
output.length=nan(N_y,N_x);
output.height=nan(N_y,N_x);
output.x_node=nan(N_y,N_x);
output.y_node=nan(N_y,N_x);
output.Interval=nan(N_y,N_x);
output.Ping_S=nan(N_y,N_x);
output.Ping_E=nan(N_y,N_x);
output.Sample_S=nan(N_y,N_x);
output.Sample_E=nan(N_y,N_x);
output.Range_mean=nan(N_y,N_x);
output.Layer_depth_min=nan(N_y,N_x);
output.Layer_depth_max=nan(N_y,N_x);
output.Range_ref_min=nan(N_y,N_x);
output.Range_ref_max=nan(N_y,N_x);
output.Layer=nan(N_y,N_x);
output.Dist_E=nan(N_y,N_x);
output.Dist_S=nan(N_y,N_x);
output.VL_E=nan(N_y,N_x);
output.VL_S=nan(N_y,N_x);
output.Time_E=nan(N_y,N_x);
output.Time_S=nan(N_y,N_x);
output.Lat_S=nan(N_y,N_x);
output.Lon_S=nan(N_y,N_x);
output.Lat_E=nan(N_y,N_x);
output.Lon_E=nan(N_y,N_x);
output.ABC=zeros(N_y,N_x);
output.NASC=zeros(N_y,N_x);
output.Thickness_esp2=nan(N_y,N_x);
output.Thickness_mean=nan(N_y,N_x);
output.Nb_good_pings=nan(N_y,N_x);
output.Nb_good_pings_esp2=nan(N_y,N_x);
output.PRC=nan(N_y,N_x);



end
