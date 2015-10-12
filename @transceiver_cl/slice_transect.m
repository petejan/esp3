function output=slice_transect(trans_obj,varargin)

p = inputParser;
init_reg=struct('name','','id',[],'unique_id',[],'startDepth',[],'finishDepth',[],'startSlice',[],'finishSlice',[]);

addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addParameter(p,'reg',init_reg,@isstruct);
addParameter(p,'Slice_w',100,@(x) x>0);
addParameter(p,'Slice_units','pings',@(unit) ~isempty(strcmp(unit,{'pings','meters'})));

parse(p,trans_obj,varargin{:});

reg=p.Results.reg;
Slice_w=p.Results.Slice_w;
Slice_units=p.Results.Slice_units;


if ~isempty([reg(:).id])
    idx_reg=trans_obj.list_regions_Unique_ID([reg(:).unique_id]);
else
    idx_reg=[];
end


switch Slice_units
    case 'pings'
        idx_pings=trans_obj.Data.Number;
        bins=unique([idx_pings(1):Slice_w:idx_pings(end) idx_pings(end)]);
        binStart = [idx_pings(1) bins(2:end-1)];
        binEnd = bins(2:end);
    case 'meters'
        dist=trans_obj.GPSDataPing.Dist;
        bins=unique([dist(1):Slice_w:dist(end) dist(end)]);
        binStart = [dist(1) bins(2:end-1)];
        binEnd = bins(2:end);
end

numSlices = length(binStart); % num_slices
slice_abscf=zeros(1,length(binStart));
nb_good_pings=zeros(1,length(binStart));
idx_bins_S=nan(1,length(binStart));
idx_bins_E=nan(1,length(binStart));

for k = 1:length(binStart); % sum up abscf data according to bins
    switch Slice_units
        case 'pings'
            [~,idx_bins_S(k)]=nanmin(abs(trans_obj.Data.Number-binStart(k)));
            [~,idx_bins_E(k)]=nanmin(abs(trans_obj.Data.Number-binEnd(k)));
        case 'meters'
            [~,idx_bins_S(k)]=nanmin(abs(trans_obj.GPSDataPing.Dist-binStart(k)));
            [~,idx_bins_E(k)]=nanmin(abs(trans_obj.Data.Number-binEnd(k)));
    end
end



for iuu=1:length(idx_reg)
    reg_curr=trans_obj.Regions(idx_reg(iuu));
    regCellInt=reg_curr.Output;
    if ~isempty([reg(:).id])
        regCellIntSub = getCellIntSubSet(regCellInt,reg(iuu),reg_curr.Reference);
    else
        regCellIntSub=regCellInt;
    end
    Sa_lin = nansum(regCellIntSub.Sa_lin)./nanmax(regCellIntSub.Nb_good_pings_esp2);%sum up all abcsf per vertical slice   
    att=zeros(1,length(Sa_lin));
    for k = 1:length(binStart); % sum up abscf data according to bins
        switch Slice_units
            case 'pings'
                t_start=nanmax(regCellIntSub.Ping_S);
            case 'meters'
                t_start=nanmax(regCellIntSub.Dist_S);
        end
        ix = (t_start>=binStart(k) &  t_start<binEnd(k))& ~att;
        att(ix)=1;
        nb_good_pings(k)=nanmax(nansum(regCellIntSub.Nb_good_pings_esp2(ix)),nb_good_pings(k));
        slice_abscf(k) = (slice_abscf(k)+nansum(Sa_lin(ix)));
    end
end

output.slice_abscf=slice_abscf;
output.slice_size=Slice_w;
output.num_slices=numSlices;
output.nb_good_pings=nb_good_pings;
output.slice_lat=trans_obj.GPSDataPing.Lat(round((idx_bins_S+idx_bins_E)/2));
output.slice_lon=trans_obj.GPSDataPing.Long(round((idx_bins_S+idx_bins_E)/2));
output.slice_lat_esp2=trans_obj.GPSDataPing.Lat(idx_bins_S);
output.slice_lon_esp2=trans_obj.GPSDataPing.Long(idx_bins_S);

end