%Just a test function to see if we could work with Sparse matrices in the
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
bad_trans_vec=double(trans_obj.Bottom.Tag==0);
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
sub_bad_trans_vec=bad_trans_vec(idx_pings);

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
% [~,sub_dist_mat]=meshgrid(sub_dist,sub_r);
% [sub_bad_trans_vec_mat,~]=meshgrid(sub_bad_trans_vec,sub_r);
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

if p.Results.keep_bottom==0
    Sv_reg_lin(y_mat_ori>=bot_mat)=nan;
end

x_mat_idx=floor(bsxfun(@minus,x_mat,x_mat(:,1))/cell_w)+1;

switch region.Reference
    case {'Bottom' 'line'}       
        y_mat_idx=floor(y_mat/cell_h);
        y_mat_idx=y_mat_idx-nanmin(y_mat_idx(:))+1;
    otherwise
        y_mat_idx=floor(bsxfun(@minus,y_mat,y_mat(1,:))/cell_h)+1;
end
        

Sv_reg_lin_tmp=Sv_reg_lin;
Sv_reg_lin_tmp(~Mask)=nan;

Sa_lin_sparse = accumarray([y_mat_idx(:) x_mat_idx(:)],Sv_reg_lin_tmp(:),[],@nansum)*dr;

[N_y,N_x]=size(Sa_lin_sparse);

output.Sa_lin=Sa_lin_sparse;

output.nb_samples=accumarray([y_mat_idx(:) x_mat_idx(:)],Sv_reg_lin_tmp(:),[],@(x) sum(~isnan(x)));

output.x_node=accumarray([y_mat_idx(:) x_mat_idx(:)],x_mat(:),[],@mean,NaN );
output.y_node=accumarray([y_mat_idx(:) x_mat_idx(:)],y_mat(:),[],@mean,NaN );


output.Sa_lin=zeros(N_y,N_x);


output.Ping_S=repmat(accumarray(x_mat_idx(1,:)',sub_pings(:),[],@nanmin),1,N_y)';
output.Ping_E=repmat(accumarray(x_mat_idx(1,:)',sub_pings(:),[],@nanmax),1,N_y)';

output.Nb_good_pings=repmat(accumarray(x_mat_idx(1,:)',(sub_bad_trans_vec(:))==0,[],@nansum),1,N_y)';

output.Nb_good_pings_esp2=output.Nb_good_pings;

output.Sample_S=accumarray([y_mat_idx(:) x_mat_idx(:)],sub_samples_mat(:),[],@nanmin);
output.Sample_E=accumarray([y_mat_idx(:) x_mat_idx(:)],sub_samples_mat(:),[],@nanmax);

output.Layer_depth_min=accumarray([y_mat_idx(:) x_mat_idx(:)],sub_r_mat(:).*Mask(:),[],@nanmin);
output.Layer_depth_max=accumarray([y_mat_idx(:) x_mat_idx(:)],sub_r_mat(:).*Mask(:),[],@nanmax);


output.Range_mean=(output.Layer_depth_min+output.Layer_depth_max)/2;
switch region.Cell_h_unit
    case 'samples'
        output.Range_ref_min=accumarray([y_mat_idx(:) x_mat_idx(:)],y_mat(:),[],@nanmin)/dr;
        output.Range_ref_max=accumarray([y_mat_idx(:) x_mat_idx(:)],y_mat(:),[],@nanmax)/dr;
        output.height=(output.Layer_depth_max-output.Layer_depth_min)/dr;
    case 'meters'
        output.height=(output.Layer_depth_max-output.Layer_depth_min);
        output.Range_ref_min=accumarray([y_mat_idx(:) x_mat_idx(:)],y_mat(:),[],@nanmin);
        output.Range_ref_max=accumarray([y_mat_idx(:) x_mat_idx(:)],y_mat(:),[],@nanmax);     
end

output.Thickness_esp2=abs(output.Layer_depth_max-output.Layer_depth_min)+dr;

output.Dist_E=repmat(accumarray(x_mat_idx(1,:)',sub_dist,[],@nanmin),1,N_y)';
output.Dist_S=repmat(accumarray(x_mat_idx(1,:)',sub_dist,[],@nanmax),1,N_y)';
output.length=(output.Dist_E-output.Dist_S);

output.Time_E=repmat(accumarray(x_mat_idx(1,:)',sub_time,[],@nanmin),1,N_y)';
output.Time_S=repmat(accumarray(x_mat_idx(1,:)',sub_time,[],@nanmin),1,N_y)';

output.Lat_S=repmat(accumarray(x_mat_idx(1,:)',sub_lat,[],@nanmin),1,N_y)';
output.Lon_S=repmat(accumarray(x_mat_idx(1,:)',sub_lon,[],@nanmin),1,N_y)';
output.Lat_E=repmat(accumarray(x_mat_idx(1,:)',sub_lat,[],@nanmax),1,N_y)';
output.Lon_E=repmat(accumarray(x_mat_idx(1,:)',sub_lon,[],@nanmin),1,N_y)';


output.Sv_mean_lin_esp2=Sa_lin_sparse./(output.Nb_good_pings_esp2.*output.Thickness_esp2);
output.Sv_mean_lin=Sa_lin_sparse./output.nb_samples/dr;

output.PRC=output.nb_samples*dr./(output.Nb_good_pings.*output.Thickness_esp2)*100;

idx_nan=(output.Sv_mean_lin_esp2==0);
output.Sv_mean_lin_esp2(idx_nan)=nan;

output.Thickness_mean=1./output.Nb_good_pings.*output.nb_samples*dr;

output.ABC=output.Thickness_mean.*output.Sv_mean_lin;
output.NASC=4*pi*1852^2*output.ABC;
output.Lon_S(output.Lon_S>180)=output.Lon_S(output.Lon_S>180)-360;


fields=fieldnames(output);
idx_zeros=find(nansum(output.Sv_mean_lin,2)==0);
idx_rem=[];
if length(idx_zeros)>=2
   if idx_zeros(1)==1;
       idx_rem=idx_zeros(1:find(abs(diff(idx_zeros))>1,1));  
   end
   
   if idx_zeros(end)==size(output.Sv_mean_lin,1);
       idx_rem=union(idx_rem,idx_zeros(find(abs(diff([1;idx_zeros]))>1,1,'last')):idx_zeros(end));  
   end
end

for ifi=1:length(fields)
    output.(fields{ifi})(idx_rem,:)=[];
end




end
