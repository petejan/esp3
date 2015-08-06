function integrate_region(region,Transceiver)

Sv=Transceiver.Data.get_datamat('svdenoised');
if isempty(Sv)
    Sv=Transceiver.Data.get_datamat('sv');
end
    

idx_pings=region.Idx_pings;
idx_r=region.Idx_r;

if isempty(Sv)
    warning('No Sv, cannot integrate');
    return;
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

idx=list_regions_type(Transceiver,'Bad Data');

for i=idx
    curr_reg=Transceiver.Regions(i);
    idx_r_curr=curr_reg.Idx_r;
    idx_pings_curr=curr_reg.Idx_pings;
    switch curr_reg.Shape
        case 'Rectangular'
            Sv(idx_r_curr,idx_pings_curr)=NaN;
        case 'Polygon'
            Sv_temp=Sv(idx_r_curr,idx_pings_curr);
            Sv_temp(~isnan(curr_reg.Sv_reg))=NaN;
            Sv(idx_r_curr,idx_pings_curr)= Sv_temp;
    end
end

switch region.Type
    case 'Bad Data'
        region.Tag='';
    otherwise 
        region.Tag='UNC';
end


IdxBad=Transceiver.IdxBad;
Sv(:,IdxBad)=NaN;
bot_r=Transceiver.Bottom.Range;
bot_sple=Transceiver.Bottom.Sample_idx;
if isempty(bot_r)
    bot_r=ones(size(pings))*range(end)+1;
    bot_sple=ones(size(pings))*samples(end)+1;
end

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
            Sv_temp=Sv(idx_r,idx_pings);
            Sv_temp(isnan(region.Sv_reg))=NaN;   
            Sv_reg=Sv_temp;
        else
            region.Shape='Rectangular';
            Sv_reg=Sv(idx_r,idx_pings);
        end
    case 'Rectangular'
        Sv_reg=Sv(idx_r,idx_pings);
end


Mask=~isnan(Sv_reg);

cell_w=region.Cell_w;
cell_h=region.Cell_h;

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

[x_mat,y_mat]=meshgrid(x,y);
y_mat_ori=y_mat;
y_mat=y_mat-line_mat;


X=x(1):cell_w:x(end);

Y0=nanmin(y_mat(:));
Y1=nanmax(y_mat(:));

Y=Y0:cell_h:Y1;


X=[X x(end)];
X=unique(X);

Y=[Y y(end)];
Y=unique(Y);


N_x=length(X)-1;
N_y=length(Y)-1;
x_c=(X(2:end)+X(1:end-1))/2;
y_c=(Y(2:end)+Y(1:end-1))/2;

x_res=(X(2:end)-X(1:end-1))/2;
y_res=(Y(2:end)-Y(1:end-1))/2;

region.Output.Sv_mean=nan(N_y,N_x);
region.Output.Sa=nan(N_y,N_x);
region.Output.Sv_max=nan(N_y,N_x);
region.Output.Sv_min=nan(N_y,N_x);
region.Output.nb_samples=nan(N_y,N_x);
region.Output.length=2*repmat(x_res,N_y,1);
region.Output.height=2*repmat(y_res',1,N_x);
region.Output.x_node=repmat(x_c,N_y,1);
region.Output.y_node=repmat(y_c',1,N_x);

region.Output.Interval=nan(N_y,N_x);
region.Output.Ping_S=nan(N_y,N_x);
region.Output.Ping_E=nan(N_y,N_x);
region.Output.Layer_depth_min=nan(N_y,N_x);
region.Output.Layer_depth_max=nan(N_y,N_x);
region.Output.y_min=nan(N_y,N_x);
region.Output.y_max=nan(N_y,N_x);
region.Output.y_mean=nan(N_y,N_x);
region.Output.Layer=nan(N_y,N_x);
region.Output.Dist_M=nan(N_y,N_x);
region.Output.VL_E=nan(N_y,N_x);
region.Output.VL_S=nan(N_y,N_x);
region.Output.Time_M=nan(N_y,N_x);
region.Output.Time_E=nan(N_y,N_x);
region.Output.Time_S=nan(N_y,N_x);
region.Output.Lat_M=nan(N_y,N_x);
region.Output.Lon_M=nan(N_y,N_x);
region.Output.Lat_S=nan(N_y,N_x);
region.Output.Lon_S=nan(N_y,N_x);
region.Output.Lat_E=nan(N_y,N_x);
region.Output.Lon_E=nan(N_y,N_x);
%region.Output.PRC_ABC=nan(N_y,N_x);
region.Output.ABC=nan(N_y,N_x);
%region.Output.PRC_NASC=nan(N_y,N_x);
region.Output.NASC=nan(N_y,N_x);
region.Output.Thickness_mean=nan(N_y,N_x);
region.Output.Nb_good_pings=nan(N_y,N_x);

Mask=Mask&(y_mat<bot_mat);


for i=1:N_x
    idx_red=(((x_mat-x_c(i)))<x_res(i))&(((x_mat-x_c(i)))>=-x_res(i))&Mask;
%     idx_red_cell=(((x_mat-x_c(i)))<=x_res(i))&(((x_mat-x_c(i)))>=-x_res(i));
%     
    idx_bin_x=find((((x-x_c(i)))<x_res(i))&(((x-x_c(i)))>=-x_res(i)));
    region.Output.Nb_good_pings(:,i)=length(idx_bin_x);
    if~isempty((idx_bin_x))
        region.Output.Interval(:,i)=i;
        region.Output.Dist_M(:,i)=nanmean(sub_dist(idx_bin_x));
        region.Output.Time_M(:,i)=nanmean(sub_time(idx_bin_x));
        region.Output.Time_S(:,i)=(sub_time(idx_bin_x(1)));
        region.Output.Time_E(:,i)=(sub_time(idx_bin_x(end)));
        region.Output.Lat_M(:,i)=nanmean(sub_lat(idx_bin_x));
        region.Output.Lon_M(:,i)=nanmean(sub_lon(idx_bin_x));
        region.Output.Lat_S(:,i)=(sub_lat(idx_bin_x(1)));
        region.Output.Lon_S(:,i)=(sub_lon(idx_bin_x(1)));
        region.Output.Lat_E(:,i)=(sub_lat(idx_bin_x(end)));
        region.Output.Lon_E(:,i)=(sub_lon(idx_bin_x(end)));
        region.Output.Ping_S(:,i)=(sub_x(idx_bin_x(1)));
        region.Output.Ping_E(:,i)=(sub_x(idx_bin_x(end)));
        region.Output.VL_S(:,i)=(sub_dist(idx_bin_x(1)));
        region.Output.VL_E(:,i)=(sub_dist(idx_bin_x(end)));
    else
        break;
    end
    
    Sv_red=Sv_reg(idx_red);
    y_mat_red=y_mat(idx_red);
    y_mat_ori_red=y_mat_ori(idx_red);
    
    
   %Sv_red=10*log10(70/100*10.^(Sv_red/10));
            
    for j=1:N_y   
        idx_bin=(((y_mat_red-y_c(j)))<y_res(j))&(((y_mat_red-y_c(j)))>=-y_res(j));       
        region.Output.Sv_mean(j,i)=10*log10(nanmean(10.^(Sv_red(idx_bin)/10)));        
        region.Output.Sa(j,i)=10*log10(nansum(10.^(Sv_red(idx_bin)/10)*dr));
        if~isempty(Sv_red(idx_bin))
            region.Output.Sv_min(j,i)=nanmin(Sv_red(idx_bin));
            region.Output.Sv_max(j,i)=nanmax(Sv_red(idx_bin));
            region.Output.nb_samples(j,i)=nansum(idx_bin(:));
            region.Output.y_mean(j,i)=nanmean(y_mat_ori_red(idx_bin));
            region.Output.Layer(j,i)=j;
            region.Output.y_min(j,i)=nanmin(y_mat_ori_red(idx_bin));
            region.Output.y_max(j,i)=nanmax(y_mat_ori_red(idx_bin));
            region.Output.Thickness_mean(j,i)=dr*nansum(idx_bin)/(region.Output.Nb_good_pings(j,i));
        end
        
    end
end


% region.Output.PRC_ABC
% region.Output.ABC
% region.Output.PRC_NASC
% region.Output.NASC


switch region.Cell_h_unit
    case 'samples'
        region.Output.Range_mean(~isnan(region.Output.y_mean))=range(round(region.Output.y_mean(~isnan(region.Output.y_mean))));
        region.Output.Layer_depth_min(~isnan(region.Output.y_min))=range(round(region.Output.y_min(~isnan(region.Output.y_min))));
        region.Output.Layer_depth_max(~isnan(region.Output.y_max))=range(round(region.Output.y_max(~isnan(region.Output.y_max))));
    case 'meters'
        region.Output.Range_mean=region.Output.y_mean;
        region.Output.Layer_depth_min=region.Output.y_min;
        region.Output.Layer_depth_max=region.Output.y_max;
end

region.Output.ABC=region.Output.Thickness_mean.*10.^(region.Output.Sv_mean/10);
region.Output.NASC=4*pi*1852^2*region.Output.ABC;


end