function int_result=integrate_region_comp(region,Transceiver,idx_pings,idx_r)

Sv=Transceiver.Data.get_datamat('Sv');
if isempty(Sv)
    error('No Sv, cannot integrate');
end

range=double(Transceiver.Data.Range);
samples=(1:length(range))';
dr=nanmean(diff(range));
pings=double(Transceiver.Data.Number);
time=double(Transceiver.Data.Time);

dist=Transceiver.GPSDataPing.Dist;
lat=Transceiver.GPSDataPing.Lat;
lon=Transceiver.GPSDataPing.Long;

if isempty(dist)
    dist=nan(size(time));
    lat=nan(size(time));
    lon=nan(size(time));
end

Sv(:,Transceiver.IdxBad)=NaN;
bot_r=Transceiver.Bottom.Range;
bot_sple=Transceiver.Bottom.Sample_idx;
bot_r(bot_r==0)=range(end);
bot_sple(bot_sple==0)=samples(end);
bot_r(isnan(bot_r))=range(end);
bot_sple(isnan(bot_sple))=samples(end);


sub_y=samples(idx_r);
sub_x=pings(idx_pings);
sub_r=range(idx_r);
sub_dist=dist(idx_pings);
sub_time=time(idx_pings);
sub_lat=lat(idx_pings);
sub_lon=lon(idx_pings);


switch region.Cell_h_unit
    case 'samples'
        y=sub_y;
        bot_int=bot_sple(idx_pings);
    case 'meters'
        y=sub_r;
        bot_int=bot_r(idx_pings);
end

switch region.Cell_w_unit
    case 'pings'
        x=sub_x;
    case 'meters'
        x=sub_dist;
end

switch region.Reference
    case 'Surface'
        line_ref=zeros(size(x));
    otherwise
        line_ref=bot_int;
end

switch region.Shape
    case 'Polygon'
        if ~isempty(region.Sv_reg)
            Sv_reg=region.Sv_reg;
        else
            region.Shape='Rectangular';
            Sv_reg=Sv(idx_r,idx_pings);
        end
    case 'Rectangular'
        Sv_reg=Sv(idx_r,idx_pings);
end


if size(line_ref,2)~=size(Sv_reg,2)
    line_ref=line_ref';
end

if size(bot_int,2)~=size(Sv_reg,2)
    bot_int=bot_int';
end

if ~isempty(line_ref)&&length(line_ref)>1
    line_mat=repmat(line_ref,size(Sv_reg,1),1);
elseif length(line_ref)==1
    line_mat=line_ref*ones(size(Sv_reg));
else
    line_mat=zeros(size(Sv_reg));
end

if ~isempty(bot_int)
    bot_mat=repmat(bot_int,size(Sv_reg,1),1);
else
    bot_mat=y(end)*ones(size(Sv_reg));
end

bot_mat(isnan(bot_mat))=y(end);
bot_mat=bot_mat-line_mat;

[~,y_mat]=meshgrid(x,y);
y_mat_ori=y_mat;
y_mat=y_mat-line_mat;
Mask=~isnan(Sv_reg);

Mask=Mask&(y_mat<bot_mat);
Sv_reg(Mask)=NaN;


int_result.Dist_M=nanmean(sub_dist(:));
int_result.Time_M=nanmean(sub_time(:));
int_result.Time_S=(sub_time(1));
int_result.Time_E=(sub_time(end));

int_result.Lat_M=nanmean(sub_lat(:));
int_result.Lon_M=nanmean(sub_lon(:));
int_result.Lat_S=(sub_lat(1));
int_result.Lon_S=(sub_lon(1));
int_result.Lat_E=(sub_lat(end));
int_result.Lon_E=(sub_lon(end));


int_result.Ping_S=(sub_x(1));
int_result.Ping_E=(sub_x(end));
int_result.VL_S=(sub_dist(1));
int_result.VL_E=(sub_dist(end));


int_result.Sv_mean=10*log10(nanmean(10.^(Sv_reg(:)/10)));
int_result.Sv_min=nanmin(Sv_reg(:));
int_result.Sv_max=nanmax(Sv_reg(:));
int_result.nb_samples=nansum(Mask(:));
int_result.y_mean=nanmean(y_mat_ori(:));
int_result.y_min=nanmin(y_mat_ori(:));
int_result.y_max=nanmax(y_mat_ori(:));

int_result.Thickness_mean=dr*nansum(Mask(:))/(int_result.Ping_E-int_result.Ping_S+1);


switch region.Cell_h_unit
    case 'samples'
        int_result.Range_mean=range(round(int_result.y_mean));
        int_result.Layer_depth_min=range(round(int_result.y_min));
        int_result.Layer_depth_max=range(round(int_result.y_max));
    case 'meters'
        int_result.Range_mean=(int_result.y_mean);
        int_result.Layer_depth_min=nanmin(y_mat_ori(:));
        int_result.Layer_depth_max=nanmax(y_mat_ori(:));
end

int_result.ABC=int_result.Thickness_mean.*10.^(int_result.Sv_mean/10);
int_result.NASC=4*pi*1852^2*int_result.ABC;


end