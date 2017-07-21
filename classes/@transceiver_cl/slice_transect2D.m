function [output,regCellInt]=slice_transect2D(trans_obj,varargin)

p = inputParser;


addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addParameter(p,'regIDs',[],@isnumeric);
addParameter(p,'Slice_w',50,@(x) x>0);
addParameter(p,'Slice_w_units','meters',@(unit) ~isempty(strcmp(unit,{'pings','meters'})));
addParameter(p,'Slice_h',10,@(x) x>0);
addParameter(p,'StartTime',0,@(x) x>0);
addParameter(p,'EndTime',1,@(x) x>0);
addParameter(p,'Reference','Surface',@(ref) ~isempty(strcmpi(ref,{'Surface','Bottom'})));

parse(p,trans_obj,varargin{:});

Slice_w=p.Results.Slice_w;
Slice_w_units=p.Results.Slice_w_units;
Slice_h=p.Results.Slice_h;


if ~isempty(p.Results.regIDs)
    idx_reg=trans_obj.find_regions_Unique_ID(p.Results.regIDs);
else
    idx_reg=1:numel(trans_obj.Regions);
end

% if isempty(idx_reg)
%     output=[];
%     regCellInt={};
%     return;
% end

if p.Results.StartTime==0
    st=trans_obj.Time(1);
else
    st=p.Results.StartTime;
end

if p.Results.EndTime==1
    et=trans_obj.Time(end);
else
    et=p.Results.EndTime;
end

idx_valid=trans_obj.Time>=st&trans_obj.Time<=et;


switch Slice_w_units
    case 'pings'
        Slice_hori_ref=trans_obj.get_transceiver_pings(idx_valid);
    case 'meters'
        Slice_hori_ref=trans_obj.GPSDataPing.Dist(idx_valid);
end

cells_hori=unique([Slice_hori_ref(1):Slice_w:Slice_hori_ref(end) Slice_hori_ref(end)]);
Slice_hori_S = cells_hori(1:end-1);
Slice_hori_E = cells_hori(2:end);


switch lower(p.Results.Reference)
    case 'surface'
        cell_vert_ref=trans_obj.get_transceiver_range();
        cells_vert=unique([cell_vert_ref(1):Slice_h:cell_vert_ref(end) cell_vert_ref(end)]);
    case 'bottom'
        cell_vert_ref=-trans_obj.get_transceiver_range();
        cells_vert=unique([cell_vert_ref(1):-Slice_h:cell_vert_ref(end) cell_vert_ref(end)]);
end



cells_vert_S = cells_vert(1:end-1);
cells_vert_E = cells_vert(2:end);

numSlices_hori = length(Slice_hori_S);
numSlices_vert = length(cells_vert_S);
cell_abscf=zeros(numSlices_vert,numSlices_hori);
cell_vbscf=zeros(numSlices_vert,numSlices_hori);
nb_tracks=zeros(numSlices_vert,numSlices_hori);
nb_st=zeros(numSlices_vert,numSlices_hori);
nb_good_pings=zeros(numSlices_vert,numSlices_hori);

idx_bins_S=nan(1,numSlices_hori);
idx_bins_E=nan(1,numSlices_hori);

idx_cells_S=nan(numSlices_vert,1);
idx_cells_E=nan(numSlices_vert,1);

for k = 1:numSlices_hori;
    [~,idx_bins_S(k)]=nanmin(abs(Slice_hori_ref-Slice_hori_S(k)));
    [~,idx_bins_E(k)]=nanmin(abs(Slice_hori_ref-Slice_hori_E(k)));
end

for k = 1:numSlices_vert;
    [~,idx_cells_S(k)]=nanmin(abs(cell_vert_ref-cells_vert_S(k)));
    [~,idx_cells_E(k)]=nanmin(abs(cell_vert_ref-cells_vert_E(k)));
end


if ~isempty(trans_obj.ST.TS_comp)
    switch Slice_w_units
        case 'pings'
            x_st=trans_obj.ST.Ping_number;
        case 'meters'
            x_st=trans_obj.ST.Dist;
    end
    
    y_st=trans_obj.ST.Target_range;
    att_st=zeros(1,length(trans_obj.ST.Ping_number));
    for k = 1:numSlices_hori;
        for j=1:numSlices_vert
            ix = (x_st>=Slice_hori_S(k) &  x_st<Slice_hori_E(k))& ~att_st&(y_st>=cells_vert_S(j) &  x_st<cells_vert_E(j));
            att_st(ix)=1;
            nb_st(j,k)=nansum(ix);
        end
    end
    
    if ~isempty(trans_obj.Tracks)
        
        xs_st_track=nan(1,length(trans_obj.Tracks.target_id));
        ys_st_track=nan(1,length(trans_obj.Tracks.target_id));
        for itracks=1:length(trans_obj.Tracks.target_id)
            idx_tr=trans_obj.Tracks.target_id{itracks};
            xs_st_track(itracks)=nanmean(x_st(idx_tr));
            ys_st_track(itracks)=nanmean(y_st(idx_tr));
        end
        
        att_tr=zeros(1,length(trans_obj.Tracks.target_id));
        for k = 1:numSlices_hori;
            for j=1:numSlices_vert
                ix = (xs_st_track>=Slice_hori_S(k) &  xs_st_track<Slice_hori_E(k))& ~att_tr&(ys_st_track>=cells_vert_S(j) &  ys_st_track<cells_vert_E(j));
                att_tr(ix)=1;
                nb_tracks(j,k)=nansum(ix);
            end
        end
    end
end
i_reg=0;
regCellInt=cell(1,length(idx_reg));


for iuu=1:length(idx_reg)
    i_reg=i_reg+1;
    reg_curr=trans_obj.Regions(idx_reg(iuu));
    
    if ~strcmp(reg_curr.Type,'Data')
        continue;
    end
    
    if ~strcmpi(p.Results.Reference,reg_curr.Reference)
        continue;
        
    end
    
 
    i_reg=i_reg+1;
    regCellInt{i_reg}=trans_obj.integrate_region_v2(reg_curr,'horiExtend',[st et]);
    if isempty(regCellInt{i_reg})
        i_reg=i_reg-1;
        continue;
    end

    
    regCellIntCurr=regCellInt{i_reg};
    Sv_mean_lin=regCellIntCurr.Sv_mean_lin_esp2;
    Sa_lin = regCellIntCurr.Sa_lin;%sum up all abcsf per vertical slice
    att=zeros(size(Sa_lin));
    switch Slice_w_units
        case 'pings'
            t_start=regCellIntCurr.Ping_S;
        case 'meters'
            t_start=regCellIntCurr.Dist_S;
    end
    
    r_start=regCellIntCurr.Range_ref_min;
    
    
    for k = 1:numSlices_hori; % sum up abscf data according to cells
        for j = 1:numSlices_vert; % sum up abscf data according to cells
            ix = (t_start>=Slice_hori_S(k) &  t_start<Slice_hori_E(k));
            iy = r_start>=cells_vert_S(j) &  r_start<cells_vert_E(j);
            i_tot =iy & ix & ~att;
            att(i_tot)=1;
            if ~any(i_tot(:))
               continue; 
            end
            nb_good_pings(j,k)=nanmax(nb_good_pings(j,k),nansum(regCellIntCurr.Nb_good_pings(i_tot(1,:))));
            cell_abscf(j,k) = cell_abscf(j,k)+nansum(Sa_lin(i_tot)./(regCellIntCurr.Nb_good_pings(i_tot)));
            cell_vbscf(j,k) = nansum([cell_vbscf(j,k) nanmean(Sv_mean_lin(i_tot))]);
        end
    end
end


regCellInt(cellfun(@isempty,regCellInt))=[];

output.cell_abscf=cell_abscf;
output.cell_vbscf=cell_vbscf;
output.cell_size=Slice_w;
output.num_slices=numSlices_hori;
output.nb_good_pings=nb_good_pings;
if ~isempty(trans_obj.GPSDataPing.Lat)
    output.cell_lat=trans_obj.GPSDataPing.Lat(round((idx_bins_S+idx_bins_E)/2))';
    output.cell_lon=trans_obj.GPSDataPing.Long(round((idx_bins_S+idx_bins_E)/2))';
    output.cell_lat_esp2=trans_obj.GPSDataPing.Lat(idx_bins_S)';
    output.cell_lon_esp2=trans_obj.GPSDataPing.Long(idx_bins_S)';
else
    output.cell_lat=nan(size(nb_good_pings));
    output.cell_lon=nan(size(nb_good_pings));
    output.cell_lat_esp2=nan(size(nb_good_pings));
    output.cell_lon_esp2=nan(size(nb_good_pings));
end
range=trans_obj.get_transceiver_range();

switch lower(p.Results.Reference)
    case 'surface'
        output.cell_range_start=range(idx_cells_S);
        output.cell_range_end=range(idx_cells_E);
    case 'bottom'
        output.cell_range_start=-range(idx_cells_S);
        output.cell_range_end=-range(idx_cells_E);
end

output.cell_dist_start=trans_obj.GPSDataPing.Dist(idx_bins_S);
output.cell_dist_end=trans_obj.GPSDataPing.Dist(idx_bins_E);
output.cell_time_start=trans_obj.Time(idx_bins_S);
output.cell_time_end=trans_obj.Time(idx_bins_E);
output.cell_nb_tracks=nb_tracks;
output.cell_nb_st=nb_st;
end