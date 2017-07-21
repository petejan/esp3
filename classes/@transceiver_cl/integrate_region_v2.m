%% integrate_region_v2.m
%
% Integrate echogram
%
%% Help
%
% *USE*
%
% output = integrate_region_v2(trans_obj,region) integrates acoustic data
% in trans_obj according to region.
%
% *INPUT VARIABLES*
%
% * |trans_obj|: TODO: write description and info on variable
% * |region|: TODO: write description and info on variable
% * |input_variable_1|: TODO: write description and info on variable
% * |input_variable_1|: TODO: write description and info on variable
% * |input_variable_1|: TODO: write description and info on variable
% * |input_variable_1|: TODO: write description and info on variable

%
% *OUTPUT VARIABLES*
%
% * |output|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-07-03: draft header and quick code cleanup (Alex Schimel).
% * YYYY-MM-DD: first version (Author). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function output = integrate_region_v2(trans_obj,region,varargin)

%% input variables management through input parser
p = inputParser;

addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addRequired(p,'region',@(x) isa(x,'region_cl'));
addParameter(p,'line_obj',[],@(x) isa(x,'line_cl')||isempty(x));
addParameter(p,'vertExtend',[0 Inf],@isnumeric);
addParameter(p,'horiExtend',[0 Inf],@isnumeric);
addParameter(p,'denoised',0,@isnumeric);
addParameter(p,'motion_correction',0,@isnumeric);
addParameter(p,'intersect_only',0,@isnumeric);
addParameter(p,'idx_regs',[],@isnumeric);
addParameter(p,'keep_bottom',0,@isnumeric);

parse(p,trans_obj,region,varargin{:});

if any([region.Cell_h region.Cell_w]==0)
    warning('Region %.0f defined with cell size =0',region.ID);
    output=[];
    return;
end

%% creating line_obj
if isempty(p.Results.line_obj)
    line_obj=line_cl('Range',zeros(size(trans_obj.get_transceiver_pings())),'Time',trans_obj.get_transceiver_time);
else
    line_obj=p.Results.line_obj;
end




idx_pings_tot=region.Idx_pings;
time=trans_obj.get_transceiver_time();
sub_time_temp=time(idx_pings_tot);
idx_keep_x=(sub_time_temp<=p.Results.horiExtend(2)&sub_time_temp>=p.Results.horiExtend(1));

if ~any(idx_keep_x)
    output=[];
    return;
end

idx_pings=idx_pings_tot(idx_keep_x);
idx_r_tot=region.Idx_r;

range=double(trans_obj.get_transceiver_range());
dr=mean(diff(range));

nb_samples=length(range);
samples=(1:nb_samples)';

line_r_ori=line_obj.Range;
line_t=line_obj.Time;

line_r=resample_data_v2(line_r_ori,line_t,time);
line_samples=round(line_r/dr);

pings=double(trans_obj.get_transceiver_pings());
bot_sple=trans_obj.get_bottom_idx();

bot_r=nan(size(bot_sple));
bot_r(~isnan(bot_sple))=range(bot_sple(~isnan(bot_sple)));
bot_r(isnan(bot_sple))=nan;

bot_r(isnan(bot_r))=inf;
bot_sple(isnan(bot_sple))=inf;



switch region.Cell_h_unit
    case 'samples'
        dn=region.Cell_h;
    case 'meters'
        dn=ceil(region.Cell_h/dr);
end

if p.Results.keep_bottom==0
    idx_keep_r=samples(idx_r_tot)<=max(bot_sple(idx_pings))+dn;
    idx_r=idx_r_tot(idx_keep_r);
else
    idx_keep_r=1:numel(idx_r_tot);
    idx_r=idx_r_tot;
end

%% getting Sv
if p.Results.denoised>0
    Sv_reg=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','svdenoised');
    if isempty(Sv_reg)
        disp('Cannot find denoised Sv, integrating normal Sv.')
        Sv_reg=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sv');
    end
else
    Sv_reg=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','sv');
end

%% motion correction
if p.Results.motion_correction>0
    motion_corr=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field','motioncompensation');
    if ~isempty(motion_corr)
        Sv_reg=Sv_reg+motion_corr;
    else
        disp('Cannot find motion corrected Sv, integrating normal Sv.')
    end
end

if isempty(Sv_reg)
    warning('No Sv, cannot integrate');
    output=[];
    return;
end

while max(idx_pings)>length(pings)
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
    
    if isempty(p.Results.idx_regs)   
        idx=trans_obj.find_regions_type('Data');
    else
        idx=p.Results.idx_regs;
    end
        
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
                Mask_reg=curr_reg.MaskReg;
                Sv_temp=Sv_reg_save(idx_r_from_reg,idx_pings_from_reg);
                Sv_temp(Mask_reg(idx_r_from_curr,idx_pings_from_curr)==0)=NaN;
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
            Mask_reg=curr_reg.MaskReg;
            Sv_temp=Sv_reg(idx_r_from_reg,idx_pings_from_reg);
            Sv_temp(Mask_reg(idx_r_from_curr,idx_pings_from_curr)>0)=NaN;
        otherwise
            Sv_temp=nan(length(idx_r_from_reg),length(idx_pings_from_reg));
    end
    Sv_reg(idx_r_from_reg,idx_pings_from_reg)= Sv_temp;
    
end

IdxBad=find(trans_obj.Bottom.Tag==0);
bad_trans_vec=double(trans_obj.Bottom.Tag==0);

if region.Remove_ST
    Mask_reg_st=trans_obj.Mask_from_st();
    Sv_reg(Mask_reg_st(idx_r,idx_pings))=NaN;
end

IdxBad_reg=intersect(IdxBad,idx_pings);
%IdxGood_reg=intersect(IdxGood,idx_pings);
Sv_reg(:,IdxBad_reg-idx_pings(1)+1)=NaN;

%% Apply region Mask_reg to data
switch region.Shape
    case 'Polygon'
        Mask_reg=region.MaskReg(idx_keep_r,idx_keep_x);
        Sv_reg(Mask_reg==0)=NaN;
end

Mask_reg=~isnan(Sv_reg);

sub_samples=samples(idx_r);
sub_pings=pings(idx_pings);
sub_r=range(idx_r);
sub_line_samples=line_samples(idx_pings);
sub_line_r=line_r(idx_pings);
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
        line_int=sub_line_samples;
    case 'meters'
        y=sub_r;
        bot_int=sub_bot_r;
        line_int=sub_line_r;
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
        Mask_reg(:,(bot_int==inf))=0;
    case 'Line'
        line_ref=line_int;
end

[bot_mat,~]=meshgrid(bot_int,sub_r);

[line_mat,~]=meshgrid(line_ref,sub_r);
line_mat(isnan(line_mat))=0;

y_mat_ori=y_mat;
y_mat=y_mat-line_mat;

switch region.Reference
    case 'Bottom'
        idx_rem_y=(y_mat<=-p.Results.vertExtend(2)|y_mat>=-p.Results.vertExtend(1)|isinf(y_mat));
    case 'Line'
        idx_rem_y=(y_mat<=-p.Results.vertExtend(2)|y_mat>=p.Results.vertExtend(2));
    otherwise
        idx_rem_y=(y_mat>=p.Results.vertExtend(2)|y_mat<=-p.Results.vertExtend(1));
end

Mask_reg(idx_rem_y)=0;

if~any(Mask_reg(:))
    output=[];
    return;
end

cell_w=region.Cell_w;
cell_h=region.Cell_h;

Sv_reg_lin=10.^(Sv_reg/10);
Mask_reg_min_bot=Mask_reg;

if p.Results.keep_bottom==0
    Mask_reg_min_bot(y_mat_ori>=bot_mat)=0;
    Mask_reg_min_bot(isnan(Sv_reg_lin))=0;
end

if ~any(Mask_reg_min_bot)
    output=[];
    return;
end


idx_x=(sum(Mask_reg)>0);
% idx_y=(sum(Mask_reg,2)>0);

x_mat_idx=floor(x_mat/cell_w);
x_mat_idx=x_mat_idx-min(x_mat_idx(Mask_reg))+1;

switch region.Reference
    case {'Bottom' 'Line'}
        y_mat_idx=ceil(y_mat/cell_h);       
    otherwise
        y_mat_idx=floor(y_mat/cell_h);        
end
y_mat_idx=y_mat_idx-min(y_mat_idx(~isinf(y_mat_idx)&Mask_reg))+1;

Sv_reg_lin(~Mask_reg_min_bot)=nan;

N_x=(max(x_mat_idx(Mask_reg))-min(x_mat_idx(Mask_reg)))+1;
N_y=(max(y_mat_idx(Mask_reg))-min(y_mat_idx(Mask_reg)))+1;

output.nb_samples=accumarray([y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)],Mask_reg_min_bot(Mask_reg_min_bot),[N_y N_x],@sum,0);

Mask_reg_sub=(output.nb_samples==0);

output.nb_samples(Mask_reg_sub)=NaN;

Sa_lin_sparse = accumarray([y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)],Sv_reg_lin(Mask_reg_min_bot),size(Mask_reg_sub),@sum,NaN)*dr;

output.Sa_lin=Sa_lin_sparse;

output.Ping_S=repmat(accumarray(x_mat_idx(1,idx_x)',sub_pings(idx_x),[],@nanmin,NaN),1,N_y)';
output.Ping_E=repmat(accumarray(x_mat_idx(1,idx_x)',sub_pings(idx_x),[],@nanmax,NaN),1,N_y)';

output.Nb_good_pings=repmat(accumarray(x_mat_idx(1,idx_x)',(sub_bad_trans_vec(idx_x))==0,[],@nansum),1,N_y)';

output.Nb_good_pings_esp2=output.Nb_good_pings;
output.Nb_good_pings_esp2(Mask_reg_sub)=NaN;

output.Sample_S=accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],sub_samples_mat(Mask_reg),size(Mask_reg_sub),@min,NaN);
output.Sample_E=accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],sub_samples_mat(Mask_reg),size(Mask_reg_sub),@max,NaN);

height_se=accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],y_mat(Mask_reg),size(Mask_reg_sub),@(x) abs(max(x)-min(x)),NaN);

switch region.Cell_h_unit
    case 'samples'
        output.Thickness_esp2=height_se*dr+dr;
    case 'meters'
        output.Thickness_esp2=height_se+dr;
end
output.Thickness_esp2(Mask_reg_sub)=NaN;

output.Layer_depth_min=accumarray([y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)],sub_r_mat(Mask_reg_min_bot),size(Mask_reg_sub),@min,NaN);
output.Layer_depth_max=accumarray([y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)],sub_r_mat(Mask_reg_min_bot),size(Mask_reg_sub),@max,NaN);

output.Range_mean=accumarray([y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)],sub_r_mat(Mask_reg_min_bot),size(Mask_reg_sub),@mean,NaN);
output.Range_mean(Mask_reg_sub)=NaN;

switch region.Cell_h_unit
    case 'samples'
        output.Range_ref_min=accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],y_mat(Mask_reg),size(Mask_reg_sub),@min,NaN)*dr;
        output.Range_ref_max=accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],y_mat(Mask_reg),size(Mask_reg_sub),@max,NaN)*dr;
    case 'meters'
        output.Range_ref_min=accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],y_mat(Mask_reg),size(Mask_reg_sub),@min,NaN);
        output.Range_ref_max=accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],y_mat(Mask_reg),size(Mask_reg_sub),@max,NaN);
end

output.Range_ref_min(Mask_reg_sub)=NaN;
output.Range_ref_max(Mask_reg_sub)=NaN;

output.Thickness_mean=1./output.Nb_good_pings.*output.nb_samples*dr;
output.Thickness_mean(Mask_reg_sub)=NaN;

output.Dist_S=repmat(accumarray(x_mat_idx(1,idx_x)',sub_dist(idx_x),[],@nanmin,nan),1,N_y)';
output.Dist_E=repmat(accumarray(x_mat_idx(1,idx_x)',sub_dist(idx_x),[],@nanmax,nan),1,N_y)';

output.Time_S=repmat(accumarray(x_mat_idx(1,idx_x)',sub_time(idx_x),[],@nanmin,nan),1,N_y)';
output.Time_E=repmat(accumarray(x_mat_idx(1,idx_x)',sub_time(idx_x),[],@nanmax,nan),1,N_y)';

output.Lat_S=repmat(accumarray(x_mat_idx(1,idx_x)',sub_lat(idx_x),[],@nanmin,nan),1,N_y)';
output.Lon_S=repmat(accumarray(x_mat_idx(1,idx_x)',sub_lon(idx_x),[],@nanmin,nan),1,N_y)';

output.Lat_E=repmat(accumarray(x_mat_idx(1,idx_x)',sub_lat(idx_x),[],@nanmax,nan),1,N_y)';
output.Lon_E=repmat(accumarray(x_mat_idx(1,idx_x)',sub_lon(idx_x),[],@nanmax,nan),1,N_y)';

output.Sv_mean_lin_esp2=Sa_lin_sparse./(output.Nb_good_pings_esp2.*output.Thickness_esp2);
output.Sv_mean_lin=Sa_lin_sparse./output.nb_samples/dr;

output.PRC=output.nb_samples*dr./(output.Nb_good_pings.*output.Thickness_esp2)*100;

idx_nan=(output.Sv_mean_lin_esp2==0);
output.Sv_mean_lin_esp2(idx_nan)=nan;

output.ABC=output.Thickness_mean.*output.Sv_mean_lin;
output.NASC=4*pi*1852^2*output.ABC;
output.Lon_S(output.Lon_S>180)=output.Lon_S(output.Lon_S>180)-360;

fields=fieldnames(output);
idx_rem=[];
idx_zeros_start=find(nansum(output.Sv_mean_lin,2)>0,1);

if idx_zeros_start>1
    idx_rem=union(idx_rem,1:idx_zeros_start-1);
end

idx_zeros_end=find(flipud(nansum(output.Sv_mean_lin,2)>0),1);
if idx_zeros_end>1
    idx_rem=union(idx_rem,N_y-((1:idx_zeros_end-1)-1));
end

for ifi=1:length(fields)
    output.(fields{ifi})(idx_rem,:)=[];
end

idx_rem=[];
idx_zeros_start=find(nansum(output.Sv_mean_lin,1)>0,1);
if idx_zeros_start>1
    idx_rem=union(idx_rem,1:idx_zeros_start-1);
end

idx_zeros_end=find(fliplr(nansum(output.Sv_mean_lin,2)>0),1);
if idx_zeros_end>1
    idx_rem=union(idx_rem,N_x-((1:idx_zeros_end-1)-1));
end

for ifi=1:length(fields)
    output.(fields{ifi})(:,idx_rem)=[];
end


end
