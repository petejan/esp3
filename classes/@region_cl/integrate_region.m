function output=integrate_region(region,trans_obj,varargin)

p = inputParser;

addRequired(p,'region',@(x) isa(x,'region_cl'));
addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addParameter(p,'vertExtend',[0 Inf],@isnumeric);
addParameter(p,'horiExtend',[0 Inf],@isnumeric);


parse(p,region,trans_obj,varargin{:});


Sv=trans_obj.Data.get_datamat('svdenoised');
if isempty(Sv)
    Sv=trans_obj.Data.get_datamat('sv');
end


idx_pings=region.Idx_pings;
idx_r=region.Idx_r;


if isempty(Sv)
    warning('No Sv, cannot integrate');
    return;
end

range=double(trans_obj.Data.get_range());
nb_samples=length(range);
samples=(1:nb_samples)';
dr=nanmean(diff(range));
pings=double(trans_obj.Data.get_numbers());
%nb_pings=length(pings);
time=double(trans_obj.Data.Time);

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

idx=list_regions_type(trans_obj,'Bad Data');

for i=idx
    curr_reg=trans_obj.Regions(i);
    if curr_reg.Unique_ID==region.Unique_ID
        continue;
    end
    idx_r_curr=curr_reg.Idx_r;
    idx_pings_curr=curr_reg.Idx_pings;
    
    mask=curr_reg.create_mask();
    Sv_temp=Sv(idx_r_curr,idx_pings_curr);
    Sv_temp(mask>0)=NaN;
    Sv(idx_r_curr,idx_pings_curr)= Sv_temp;
end


IdxBad=find(trans_obj.Bottom.Tag==0);
%IdxGood=find(trans_obj.Bottom.Tag>0);
bot_sple=trans_obj.Bottom.Sample_idx;
bot_sple(bot_sple==0)=1;
Sv(:,IdxBad)=NaN;

if region.Remove_ST
    mask_st=trans_obj.mask_from_st();
    Sv(mask_st)=NaN;
end

IdxBad_reg=intersect(IdxBad,idx_pings);
%IdxGood_reg=intersect(IdxGood,idx_pings);

if isempty(bot_sple)
    bot_sple=ones(size(pings))*samples(end);
end

bot_r=nan(size(bot_sple));
bot_r(~isnan(bot_sple))=range(bot_sple(~isnan(bot_sple)));
bot_r(isnan(bot_sple))=nan;

bot_r(isnan(bot_r))=inf;
bot_sple(isnan(bot_sple))=inf;


mask=region.create_mask();
Sv_temp=Sv(idx_r,idx_pings);
Sv_temp(mask==0)=NaN;
Sv_reg=Sv_temp;

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
    otherwise
        line_ref=bot_int;
        Mask(:,(bot_int==inf))=0;
end

[t_mat,~]=meshgrid(sub_time,sub_r);
[bot_mat,~]=meshgrid(bot_int,sub_r);
[line_mat,~]=meshgrid(line_ref,sub_r);


y_mat_ori=y_mat;
y_mat=y_mat-line_mat;

switch region.Reference
    case 'Bottom'
       idx_rem=(y_mat<-p.Results.vertExtend(2)|y_mat>p.Results.vertExtend(1))|(t_mat>p.Results.horiExtend(2)|t_mat<p.Results.horiExtend(1));
    otherwise
      idx_rem=(y_mat>p.Results.vertExtend(2)|y_mat<-p.Results.vertExtend(1))|(t_mat>p.Results.horiExtend(2)|t_mat<p.Results.horiExtend(1));
end

Mask(idx_rem)=0;

cell_w=region.Cell_w;
cell_h=region.Cell_h;


X0=nanmin(x_mat(Mask));
X1=nanmax(x_mat(Mask));

X=X0:cell_w:X1;
X=[X X1];
X=unique(X);
x_c=(X(2:end)+X(1:end-1))/2;
x_res=(X(2:end)-X(1:end-1))/2;
N_x=length(X)-1;

switch region.Reference
    case 'Surface'
        Y0=nanmin(y_mat(Mask));
        Y1=nanmax(y_mat(Mask));
        Y=Y0:cell_h:Y1;
        Y=[Y Y1];                
        y_c=(Y(2:end)+Y(1:end-1))/2;
        y_res=abs(Y(2:end)-Y(1:end-1))/2;
    otherwise
        Y1=nanmin(y_mat(Mask));
        Y=0:-cell_h:Y1;
        Y=[Y Y1];
        Y=unique(Y);
        Y=flip(Y);
        y_res=abs(((Y(2:end)-Y(1:end-1))/2));
        y_c=((Y(2:end)+Y(1:end-1))/2);
end
N_y=length(Y)-1;


output.Sv_mean_lin_esp2=nan(N_y,N_x);
output.Sv_mean_lin=nan(N_y,N_x);
% output.Sv_mean=nan(N_y,N_x);
% output.Sv_mean_esp2=nan(N_y,N_x);
output.Sa_lin=nan(N_y,N_x);
% output.Sa=nan(N_y,N_x);
% output.Sv_max=nan(N_y,N_x);
% output.Sv_min=nan(N_y,N_x);
output.nb_samples=nan(N_y,N_x);
output.length=2*repmat(x_res,N_y,1);
output.height=2*repmat(y_res',1,N_x);
output.x_node=repmat(x_c,N_y,1);
output.y_node=repmat(y_c',1,N_x);
output.Interval=nan(N_y,N_x);
output.Ping_S=nan(N_y,N_x);
output.Ping_E=nan(N_y,N_x);
%output.Ping_M=nan(N_y,N_x);
output.Sample_S=nan(N_y,N_x);
output.Sample_E=nan(N_y,N_x);
%output.Sample_M=nan(N_y,N_x);
output.Range_mean=nan(N_y,N_x);
output.Layer_depth_min=nan(N_y,N_x);
output.Layer_depth_max=nan(N_y,N_x);
output.Range_ref_min=nan(N_y,N_x);
output.Range_ref_max=nan(N_y,N_x);
output.Layer=nan(N_y,N_x);
output.Dist_E=nan(N_y,N_x);
output.Dist_S=nan(N_y,N_x);
%output.Dist_M=nan(N_y,N_x);
output.VL_E=nan(N_y,N_x);
output.VL_S=nan(N_y,N_x);
%output.Time_M=nan(N_y,N_x);
output.Time_E=nan(N_y,N_x);
output.Time_S=nan(N_y,N_x);
% output.Lat_M=nan(N_y,N_x);
% output.Lon_M=nan(N_y,N_x);
output.Lat_S=nan(N_y,N_x);
output.Lon_S=nan(N_y,N_x);
output.Lat_E=nan(N_y,N_x);
output.Lon_E=nan(N_y,N_x);
output.ABC=nan(N_y,N_x);
output.NASC=nan(N_y,N_x);
output.Thickness_esp2=nan(N_y,N_x);
output.Thickness_mean=nan(N_y,N_x);
output.Nb_good_pings=nan(N_y,N_x);
output.Nb_good_pings_esp2=nan(N_y,N_x);
output.PRC=nan(N_y,N_x);

Sv_reg_lin=10.^(Sv_reg/10);
Sv_reg_lin(y_mat_ori>=bot_mat)=nan;

for i=1:N_x
    if i==N_x
        %idx_red_old=find((((x_mat-x_c(i)))<=x_res(i))&(((x_mat-x_c(i)))>=-x_res(i))&Mask);
        idx_bin_x=((((x-x_c(i)))<=x_res(i))&(((x-x_c(i)))>=-x_res(i)));
    else
        %idx_red_old=find((((x_mat-x_c(i)))<x_res(i))&(((x_mat-x_c(i)))>=-x_res(i))&Mask);
        idx_bin_x=((((x-x_c(i)))<x_res(i))&(((x-x_c(i)))>=-x_res(i)));
    end
    idx_red=find(Mask&repmat(idx_bin_x,length(y),1));
    idx_bin_good_x=idx_bin_x;
    
    idx_bin_good_x(IdxBad_reg)=0;
    
    output.Nb_good_pings(:,i)=nansum(idx_bin_good_x);

    idx_bin_x=find(idx_bin_x);
    
    if~isempty((idx_bin_x))
        output.Interval(:,i)=i;
        output.Dist_E(:,i)=nanmin(sub_dist(idx_bin_x));
        output.Dist_S(:,i)=nanmax(sub_dist(idx_bin_x));
%         output.Dist_M(:,i)=nanmean(sub_dist(idx_bin_x));
%         output.Time_M(:,i)=nanmean(sub_time(idx_bin_x));
        output.Time_S(:,i)=sub_time(idx_bin_x(1));
        output.Time_E(:,i)=sub_time(idx_bin_x(end));
%         output.Lat_M(:,i)=nanmean(sub_lat(idx_bin_x));
%         output.Lon_M(:,i)=nanmean(sub_lon(idx_bin_x));
        output.Lat_S(:,i)=sub_lat(idx_bin_x(1));
        output.Lon_S(:,i)=sub_lon(idx_bin_x(1));
        output.Lat_E(:,i)=sub_lat(idx_bin_x(end));
        output.Lon_E(:,i)=sub_lon(idx_bin_x(end));
        output.Ping_S(:,i)=sub_pings(idx_bin_x(1));
        output.Ping_E(:,i)=sub_pings(idx_bin_x(end));
%         output.Ping_M(:,i)=nanmean(sub_pings(idx_bin_x));
        output.VL_S(:,i)=sub_dist(idx_bin_x(1));
        output.VL_E(:,i)=sub_dist(idx_bin_x(end));
    else
        break;
    end
    
    Sv_lin_red=Sv_reg_lin(idx_red);
    x_mat_red=x_mat(idx_red);
    y_mat_red=y_mat(idx_red);
    sub_r_mat_red=sub_r_mat(idx_red);
    sub_samples_mat_red=sub_samples_mat(idx_red);
    %Sv_red=10*log10(70/100*10.^(Sv_red/10));
    idx_red_pos=(Sv_lin_red>0);

    for j=1:N_y
        if j==N_y
            idx_bin_2=(((y_mat_red-y_c(j)))<=y_res(j))&(((y_mat_red-y_c(j)))>=-y_res(j));
        else
            idx_bin_2=(((y_mat_red-y_c(j)))<y_res(j))&(((y_mat_red-y_c(j)))>=-y_res(j));
        end
        
        idx_bin=find(idx_bin_2&idx_red_pos);
        idx_bin_2=find(idx_bin_2);
       
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
        nb_idx=length(idx_bin);
        if nb_idx>0
            height_se=abs(max(y_mat_red(idx_bin_2))-min(y_mat_red(idx_bin_2)));
                    switch region.Cell_h_unit
                        case 'samples'
                            output.Range_ref_min(j,i)=min(y_mat_red(idx_bin_2)/dr);
                            output.Range_ref_max(j,i)=max(y_mat_red(idx_bin_2)/dr);
                        case 'meters'
                            output.Range_ref_min(j,i)=min(y_mat_red(idx_bin_2));
                            output.Range_ref_max(j,i)=max(y_mat_red(idx_bin_2));
                    end

            ping_cell=setdiff(x_mat_red(idx_bin),IdxBad_reg);
            %ping_cell=intersect(x_mat_red(idx_bin),IdxGood_reg);
            output.Nb_good_pings_esp2(j,i)=length(ping_cell);
            
             
            output.nb_samples(j,i)=nb_idx;
            output.Range_mean(j,i)=mean(sub_r_mat_red(idx_bin));
            output.Layer(j,i)=j;
            output.Layer_depth_min(j,i)=min(sub_r_mat_red(idx_bin));
            output.Layer_depth_max(j,i)=max(sub_r_mat_red(idx_bin));
            
            switch region.Cell_h_unit
                case 'samples'
                    output.Thickness_esp2(j,i)=height_se*dr+dr;
                case 'meters'
                    output.Thickness_esp2(j,i)=height_se+dr;
            end
            
            
            output.PRC(j,i)=nb_idx*dr/(output.Nb_good_pings(j,i)*output.Thickness_esp2(j,i))*100;
            
            output.Thickness_mean(j,i)=1/output.Nb_good_pings(j,i)*nb_idx*dr;

            sum_sv_lin_temp=nansum(Sv_lin_red(idx_bin));
            output.Sv_mean_lin_esp2(j,i)=sum_sv_lin_temp/(output.Nb_good_pings_esp2(j,i)*output.Thickness_esp2(j,i))*dr; 
            output.Sv_mean_lin(j,i)=sum_sv_lin_temp/nb_idx;
            
%             output.Sv_mean_esp2(j,i)=10*log10(output.Sv_mean_lin_esp2(j,i));
%             output.Sv_mean(j,i)=10*log10(nanmean(Sv_lin_red(idx_bin)));
            
            output.Sa_lin(j,i)=sum_sv_lin_temp*dr;
%             output.Sa(j,i)=10*log10(output.Sa_lin(j,i));
            
%            sv_cell=Sv_lin_red(idx_bin);
            
%             output.Sv_min(j,i)=10*log10(nanmin(sv_cell));
%             output.Sv_max(j,i)=10*log10(nanmax(sv_cell));
        end
        

        if ~isempty(idx_bin_2)
            output.Sample_S(j,i)=min(sub_samples_mat_red(idx_bin_2));
            output.Sample_E(j,i)=max(sub_samples_mat_red(idx_bin_2));
            %output.Sample_M(j,i)=nanmean(sub_samples_mat_red(idx_bin_2));
        end
        
    end
end
idx_nan=(output.Sv_mean_lin_esp2==0);
% output.Sv_mean_esp2(idx_nan)=nan;
output.Sv_mean_lin_esp2(idx_nan)=nan;

output.ABC=output.Thickness_mean.*output.Sv_mean_lin;
output.NASC=4*pi*1852^2*output.ABC;
output.Lon_S(output.Lon_S>180)=output.Lon_S(output.Lon_S>180)-360;


end