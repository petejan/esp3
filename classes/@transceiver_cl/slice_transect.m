function [output,regs,regCellIntOut]=slice_transect(trans_obj,varargin)

p = inputParser;
init_reg=struct('name','','id',nan,'unique_id',nan,'startDepth',nan,'finishDepth',nan,'startSlice',nan,'finishSlice',nan);

addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addParameter(p,'reg',init_reg,@(x) isstruct(x)||isempty(x));
addParameter(p,'Slice_w',50,@(x) x>0);
addParameter(p,'Slice_units','pings',@(unit) ~isempty(strcmp(unit,{'pings','meters'})));
addParameter(p,'StartTime',0,@(x) x>0);
addParameter(p,'EndTime',Inf,@(x) x>0);
addParameter(p,'Denoised',0,@isnumeric);
addParameter(p,'Motion_correction',0,@isnumeric)
parse(p,trans_obj,varargin{:});

reg=p.Results.reg;
Slice_w=p.Results.Slice_w;
Slice_units=p.Results.Slice_units;

if isempty(reg)
    reg=init_reg;
end

if ~isempty(~isnan([reg(:).id]))
    idx_reg=trans_obj.list_regions_ID([reg(:).id]);
else
    idx_reg=[];
end


if p.Results.StartTime==0
    st=trans_obj.Data.Time(1);
else
    st=p.Results.StartTime;
end

if p.Results.EndTime==1
    et=trans_obj.Data.Time(end);
else
    et=p.Results.EndTime;
end
if ~isempty(trans_obj.GPSDataPing.Lat)
     idx_valid=find(trans_obj.Data.Time(:)>=st&trans_obj.Data.Time(:)<=et&~isnan(trans_obj.GPSDataPing.Lat(:)));
else
     idx_valid=find(trans_obj.Data.Time>=st&trans_obj.Data.Time<=et);
end

switch Slice_units
    case 'pings'
        bin_ref=trans_obj.get_transceiver_pings(idx_valid);
    case 'meters'
        bin_ref=trans_obj.GPSDataPing.Dist(idx_valid);
end

bins=unique([bin_ref(1):Slice_w:bin_ref(end) bin_ref(end)]);
binStart = bins(1:end-1);
binEnd = bins(2:end);


numSlices = length(binStart); % num_slices
slice_abscf=zeros(1,length(binStart));
nb_tracks=zeros(1,length(binStart));
nb_st=zeros(1,length(binStart));
nb_good_pings=zeros(1,length(binStart));
idx_bins_S=nan(1,length(binStart));
idx_bins_E=nan(1,length(binStart));

for k = 1:length(binStart); % sum up abscf data according to bins
    [~,idx_bins_S(k)]=nanmin(abs(bin_ref-binStart(k)));
    [~,idx_bins_E(k)]=nanmin(abs(bin_ref-binEnd(k)));
end

idx_S=idx_valid(idx_bins_S);
idx_E=idx_valid(idx_bins_E);
idx_M=idx_valid(round((idx_bins_S+idx_bins_E)/2));

if ~isempty(trans_obj.ST.TS_comp)
    x_st=trans_obj.ST.Ping_number;
    att_st=zeros(1,length(trans_obj.ST.Ping_number));
    for k = 1:length(binStart);
        ix = (x_st>=binStart(k) &  x_st<binEnd(k))& ~att_st;
        att_st(ix)=1;
        nb_st(k)=nansum(ix);
    end
end

if ~isempty(trans_obj.Tracks)
    ping_num_st=trans_obj.ST.Ping_number;
    ping_num_track=nan(1,length(trans_obj.Tracks.target_id));
    for itracks=1:length(trans_obj.Tracks.target_id)
        idx_tr=trans_obj.Tracks.target_id{itracks};
        ping_num_track(itracks)=nanmean(ping_num_st(idx_tr));
    end
    
    att_tr=zeros(1,length(trans_obj.Tracks.target_id));
    for k = 1:length(binStart);
        ix = (ping_num_track>=binStart(k) &  ping_num_track<binEnd(k))& ~att_tr;
        att_tr(ix)=1;
        nb_tracks(k)=nansum(ix);
    end
end

i_reg=0;
regCellIntOut={};
regs={};

for iuu=1:length(idx_reg)
    
    reg_curr=trans_obj.Regions(idx_reg(iuu));
   
    
    if ~strcmp(reg_curr.Type,'Data')
        continue;
    end
    
    i_reg=i_reg+1;
    reg_param=reg(find([reg(:).id]==reg_curr.ID,1));
    regCellInt=trans_obj.integrate_region(reg_curr,'vertExtend',[reg_param.startDepth reg_param.finishDepth],'horiExtend',[p.Results.StartTime p.Results.EndTime],...
        'denoised',p.Results.Denoised,'motion_correction',p.Results.Motion_correction);
    
    if isempty(regCellInt)
        i_reg=i_reg-1;
        continue;
    end
    
    if isempty(regCellInt.Sv_mean_lin)
        i_reg=i_reg-1;
        continue;
    end
    regs{i_reg}=reg_curr;
    
    Sa_lin = nansum(regCellInt.Sa_lin)./nanmax(regCellInt.Nb_good_pings_esp2);%sum up all abcsf per vertical slice
    att=zeros(1,length(Sa_lin));
    switch Slice_units
        case 'pings'
            t_start=nanmax(regCellInt.Ping_S);
        case 'meters'
            t_start=nanmax(regCellInt.Dist_S);
    end
    
    for k = 1:length(binStart); % sum up abscf data according to bins
        ix = (t_start>=binStart(k) &  t_start<binEnd(k))& ~att;
        att(ix)=1;
        nb_good_pings(k)=nanmax(nansum(regCellInt.Nb_good_pings_esp2(ix)),nb_good_pings(k));
        slice_abscf(k) = (slice_abscf(k)+nansum(Sa_lin(ix)));
    end
    regCellIntOut{i_reg}=regCellInt;
end

output.slice_abscf=slice_abscf;
output.slice_size=Slice_w;
output.num_slices=numSlices;
output.nb_good_pings=nb_good_pings;
if ~isempty(trans_obj.GPSDataPing.Lat)
    output.slice_lat=trans_obj.GPSDataPing.Lat(idx_M)';
    output.slice_lon=trans_obj.GPSDataPing.Long(idx_M)';
    output.slice_lat_esp2=trans_obj.GPSDataPing.Lat(idx_S)';
    output.slice_lon_esp2=trans_obj.GPSDataPing.Long(idx_S)';
else
    output.slice_lat=nan(size(nb_good_pings));
    output.slice_lon=nan(size(nb_good_pings));
    output.slice_lat_esp2=nan(size(nb_good_pings));
    output.slice_lon_esp2=nan(size(nb_good_pings));
end

output.slice_time_start=trans_obj.Data.Time(idx_S);
output.slice_time_end=trans_obj.Data.Time(idx_E);
output.slice_nb_tracks=nb_tracks;
output.slice_nb_st=nb_st;
end