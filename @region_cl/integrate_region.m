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

while nanmax(idx_pings)>length(pings)
    idx_pings=idx_pings-1;
end

idx_pings(idx_pings<=0)=[];

idx_r(idx_r>length(range))=[];

region.Idx_pings=idx_pings;
region.Idx_r=idx_r;

if isempty(idx_r)||isempty(idx_pings)
    warning('Cannot integrate this region, no data...');
     return;
end

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
        region.Tag='';
end

IdxBad=Transceiver.IdxBad;
bot_sple=Transceiver.Bottom.Sample_idx;
bot_sple(bot_sple==0)=1;
Sv(:,IdxBad)=NaN;

IdxBad_reg=intersect(IdxBad,idx_pings);

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

sub_samples=samples(idx_r);
sub_pings=pings(idx_pings);
sub_r=range(idx_r);
sub_dist=dist(idx_pings);
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
    otherwise
        line_ref=bot_int;
        Mask(:,(bot_int==inf))=0;
end

[bot_mat,~]=meshgrid(bot_int,sub_r);
[line_mat,~]=meshgrid(line_ref,sub_r);


y_mat_ori=y_mat;
y_mat=y_mat-line_mat;

cell_w=region.Cell_w;
cell_h=region.Cell_h;
X0=nanmin(x_mat(:));
X1=nanmax(x_mat(:));

X=X0:cell_w:X1;
X=[X x(end)];
X=unique(X);
x_c=(X(2:end)+X(1:end-1))/2;
x_res=(X(2:end)-X(1:end-1))/2;
N_x=length(X)-1;

switch region.Reference
    case 'Surface'
        Y0=nanmin(y_mat(Mask));
        Y1=nanmax(y_mat(Mask));
        Y=Y0:cell_h:Y1;
        Y=[Y nanmax(y_mat(Mask))];                
        y_c=(Y(2:end)+Y(1:end-1))/2;
        y_res=abs(Y(2:end)-Y(1:end-1))/2;
    otherwise
        Y1=nanmin(y_mat(Mask));
        Y0=0;
        Y=Y0:-cell_h:Y1;
        Y=[nanmin(y_mat(Mask)) Y];
        Y=unique(Y);
        Y=flip(Y);
        y_res=abs(((Y(2:end)-Y(1:end-1))/2));
        y_c=((Y(2:end)+Y(1:end-1))/2);
end
N_y=length(Y)-1;

region.Output.Sv_mean=nan(N_y,N_x);
region.Output.Sv_mean_lin_esp2=nan(N_y,N_x);
region.Output.Sv_mean_lin=nan(N_y,N_x);
region.Output.Sv_mean_esp2=nan(N_y,N_x);
region.Output.Sa_lin=nan(N_y,N_x);
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
region.Output.Ping_M=nan(N_y,N_x);
region.Output.Sample_S=nan(N_y,N_x);
region.Output.Sample_E=nan(N_y,N_x);
region.Output.Sample_M=nan(N_y,N_x);
region.Output.Range_mean=nan(N_y,N_x);
region.Output.Layer_depth_min=nan(N_y,N_x);
region.Output.Layer_depth_max=nan(N_y,N_x);
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
region.Output.ABC=nan(N_y,N_x);
region.Output.NASC=nan(N_y,N_x);
region.Output.Thickness_esp2=nan(N_y,N_x);
region.Output.Thickness_mean=nan(N_y,N_x);
region.Output.Nb_good_pings=nan(N_y,N_x);
region.Output.Nb_good_pings_esp2=nan(N_y,N_x);
region.Output.PRC=nan(N_y,N_x);

Sv_reg_lin=10.^(Sv_reg/10);
Sv_reg_lin(y_mat_ori>=bot_mat)=nan;

for i=1:N_x
    if i==N_x
        idx_red=(((x_mat-x_c(i)))<=x_res(i))&(((x_mat-x_c(i)))>=-x_res(i))&Mask;
        idx_bin_x=((((x-x_c(i)))<=x_res(i))&(((x-x_c(i)))>=-x_res(i)));
    else
        idx_red=(((x_mat-x_c(i)))<x_res(i))&(((x_mat-x_c(i)))>=-x_res(i))&Mask;
        idx_bin_x=((((x-x_c(i)))<x_res(i))&(((x-x_c(i)))>=-x_res(i)));
    end
     idx_bin_good_x=idx_bin_x;
    
    idx_bin_good_x(IdxBad_reg)=0;
    
    region.Output.Nb_good_pings(:,i)=nansum(idx_bin_good_x);

    idx_bin_x=find(idx_bin_x);
    
    if~isempty((idx_bin_x))
        region.Output.Interval(:,i)=i;
        region.Output.Dist_M(:,i)=nanmean(sub_dist(idx_bin_x));
        region.Output.Time_M(:,i)=nanmean(sub_time(idx_bin_x));
        region.Output.Time_S(:,i)=sub_time(idx_bin_x(1));
        region.Output.Time_E(:,i)=sub_time(idx_bin_x(end));
        region.Output.Lat_M(:,i)=nanmean(sub_lat(idx_bin_x));
        region.Output.Lon_M(:,i)=nanmean(sub_lon(idx_bin_x));
        region.Output.Lat_S(:,i)=sub_lat(idx_bin_x(1));
        region.Output.Lon_S(:,i)=sub_lon(idx_bin_x(1));
        region.Output.Lat_E(:,i)=sub_lat(idx_bin_x(end));
        region.Output.Lon_E(:,i)=sub_lon(idx_bin_x(end));
        region.Output.Ping_S(:,i)=sub_pings(idx_bin_x(1));
        region.Output.Ping_E(:,i)=sub_pings(idx_bin_x(end));
        region.Output.Ping_M(:,i)=nanmean(sub_pings(idx_bin_x));
        region.Output.VL_S(:,i)=sub_dist(idx_bin_x(1));
        region.Output.VL_E(:,i)=sub_dist(idx_bin_x(end));
    else
        break;
    end
    
    Sv_lin_red=Sv_reg_lin(idx_red);
    x_mat_red=x_mat(idx_red);
    y_mat_red=y_mat(idx_red);
    sub_r_mat_red=sub_r_mat(idx_red);
    sub_samples_mat_red=sub_samples_mat(idx_red);
    %Sv_red=10*log10(70/100*10.^(Sv_red/10));
    
    

    for j=1:N_y
        
        if j==N_y
            idx_bin=(((y_mat_red-y_c(j)))<=y_res(j))&(((y_mat_red-y_c(j)))>=-y_res(j))&Sv_lin_red>0;
            idx_bin_2=(((y_mat_red-y_c(j)))<=y_res(j))&(((y_mat_red-y_c(j)))>=-y_res(j));  
        else
            idx_bin=(((y_mat_red-y_c(j)))<y_res(j))&(((y_mat_red-y_c(j)))>=-y_res(j))&Sv_lin_red>0;
            idx_bin_2=(((y_mat_red-y_c(j)))<y_res(j))&(((y_mat_red-y_c(j)))>=-y_res(j));
        end
        
        
  
        switch region.Cell_h_unit
            case 'samples'   
                sple_num=floor(2*(y_res(j)));
                
            case 'meters'
                sple_num=floor(2*(y_res(j)/dr));
        end
 
        if isempty(sple_num)
            sple_num=1;
        elseif sple_num==0;
            sple_num=1;
        end
        
        if nansum(idx_bin)>0
            height_se=abs(nanmax(y_mat_red(idx_bin_2))-nanmin(y_mat_red(idx_bin_2)));
            ping_cell=setdiff(x_mat_red(idx_bin),IdxBad_reg);
            region.Output.Nb_good_pings_esp2(j,i)=length(ping_cell);
  
            region.Output.nb_samples(j,i)=nansum(idx_bin);
            region.Output.Range_mean(j,i)=nanmean(sub_r_mat_red(idx_bin));
            region.Output.Layer(j,i)=j;
            region.Output.Layer_depth_min(j,i)=nanmin(sub_r_mat_red(idx_bin));
            region.Output.Layer_depth_max(j,i)=nanmax(sub_r_mat_red(idx_bin));
            
            switch region.Cell_h_unit
                case 'samples'
                    region.Output.Thickness_esp2(j,i)=height_se*dr+dr;
                case 'meters'
                    region.Output.Thickness_esp2(j,i)=height_se+dr;
            end
            
            region.Output.PRC(j,i)=nansum(idx_bin)*dr/(region.Output.Nb_good_pings(j,i)*region.Output.Thickness_esp2(j,i))*100;
            
            region.Output.Thickness_mean(j,i)=nansum(idx_bin*dr)/(region.Output.Nb_good_pings(j,i));

                
            region.Output.Sv_mean_lin_esp2(j,i)=nansum(Sv_lin_red(idx_bin)*dr)/(region.Output.Nb_good_pings_esp2(j,i)*region.Output.Thickness_esp2(j,i)); 
            region.Output.Sv_mean_lin(j,i)=nanmean(Sv_lin_red(idx_bin));
            
            region.Output.Sv_mean_esp2(j,i)=10*log10(region.Output.Sv_mean_lin_esp2(j,i));
            region.Output.Sv_mean(j,i)=10*log10(nanmean(Sv_lin_red(idx_bin)));
            
            region.Output.Sa_lin(j,i)=nansum(Sv_lin_red(idx_bin)*dr);
            region.Output.Sa(j,i)=10*log10(region.Output.Sa_lin(j,i));
            
            sv_cell=Sv_lin_red(idx_bin);
            
            region.Output.Sv_min(j,i)=10*log10(nanmin(sv_cell));
            region.Output.Sv_max(j,i)=10*log10(nanmax(sv_cell));
        end
        
        if nansum(idx_bin_2)>0
            region.Output.Sample_S(j,i)=nanmin(sub_samples_mat_red(idx_bin_2));
            region.Output.Sample_E(j,i)=nanmax(sub_samples_mat_red(idx_bin_2));    
            region.Output.Sample_M(j,i)=nanmean(sub_samples_mat_red(idx_bin_2));                  
        end
        
    end
end
idx_nan=(region.Output.Sv_mean_lin_esp2==0);
region.Output.Sv_mean_esp2(idx_nan)=nan;
region.Output.Sv_mean_lin_esp2(idx_nan)=nan;

region.Output.ABC=region.Output.Thickness_mean.*10.^(region.Output.Sv_mean/10);
region.Output.NASC=4*pi*1852^2*region.Output.ABC;


end