%% integrate_region_v4.m
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
% * 2017-11-14: New version of the integration code.
% * YYYY-MM-DD: first version (Author). TODO: complete date and comment
% relying on get_data_from_region to get masks and region contents
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function output = integrate_region_v4(trans_obj,region,varargin)

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
addParameter(p,'regs',region_cl.empty(),@(x) isa(x,'region_cl'));
addParameter(p,'select_reg','all',@ischar);
addParameter(p,'keep_bottom',0,@isnumeric);
addParameter(p,'keep_all',0,@isnumeric);
addParameter(p,'sv_thr',-999,@isnumeric);

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



%% getting Sv
if p.Results.denoised>0   
    field='svdenoised';
    if ~ismember('svdenoised',trans_obj.Data.Fieldname)
        field='sv';
    end
else
    field='sv';
end

[Sv_reg,idx_r,idx_pings,bad_data_mask,bad_trans_vec,intersection_mask,below_bot_mask,mask_from_st]=get_data_from_region(trans_obj,region,...
    'field',field,...
    'vertExtend',p.Results.vertExtend,...
    'horiExtend',p.Results.horiExtend,...
    'intersect_only',p.Results.intersect_only,...
    'idx_regs',p.Results.idx_regs,...
    'regs',p.Results.regs,...
    'select_reg',p.Results.select_reg,...
    'keep_bottom',p.Results.keep_bottom,...
    'keep_all',p.Results.keep_all);

if isempty(Sv_reg)
    output=[];
    return;
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


%% Masking data
% defining overall mask for the region and masking data within region
Mask_reg = ~bad_data_mask & intersection_mask & ~mask_from_st & ~isnan(Sv_reg);
Mask_reg(:,bad_trans_vec) = false;
Sv_reg(Sv_reg<p.Results.sv_thr) = -999;
Sv_reg(~Mask_reg) = nan;


%% vectors in pings and samples

% time, range, ping counter, and sample counter vectors
sub_time = trans_obj.get_transceiver_time(idx_pings);
range_tot=trans_obj.get_transceiver_range();
sub_r = range_tot(idx_r);
sub_pings = idx_pings;
sub_samples = idx_r;

% taking the average of distance between two samples
dr = mean(diff(sub_r));

% range and sample counter for reference line?
line_r_ori = line_obj.Range;
line_t     = line_obj.Time;
sub_line_r = resample_data_v2(line_r_ori,line_t,sub_time);
sub_line_samples = round(sub_line_r/dr);

% distance, latitude and longitude
if isempty(trans_obj.GPSDataPing.Dist)
    region.Cell_w_unit = 'pings';
    sub_dist = nan(size(sub_time));
    sub_lat  = nan(size(sub_time));
    sub_lon  = nan(size(sub_time));
else
    sub_dist = trans_obj.GPSDataPing.Dist(idx_pings);
    sub_lat  = trans_obj.GPSDataPing.Lat(idx_pings);
    sub_lon  = trans_obj.GPSDataPing.Long(idx_pings);
end

% selecting the appropriate unit
switch region.Cell_h_unit
    case 'samples'
        y = sub_samples;
        bot_int = trans_obj.get_bottom_idx(idx_pings);
        line_int = sub_line_samples;
    case 'meters'
        y = sub_r;
        bot_int = trans_obj.get_bottom_range(idx_pings);
        line_int = sub_line_r;
end

switch region.Cell_w_unit
    case 'pings'
        x = sub_pings;
    case 'meters'
        x = sub_dist;
end

% missing bottom
bot_int(isnan(bot_int)) = inf;

% meshgrid the vectors in X and Y as well as range (horz) and sample counter 
[x_mat,y_mat] = meshgrid(x,y);

%[sub_pings_mat,sub_samples_mat] = meshgrid(sub_pings,sub_samples);



%% reference line -related stuff
switch region.Reference
    case 'Surface'
        line_ref = zeros(size(x));
    case 'Bottom'
        line_ref = bot_int;
        Mask_reg(:,(bot_int==inf)) = 0;
    case 'Line'
        line_ref = line_int;
end

[line_mat,~] = meshgrid(line_ref,sub_r);
line_mat(isnan(line_mat)) = 0;

% offseting Y using the reference line
y_mat = y_mat - line_mat;

% identifying which samples are beyond the range imposed by vertExtend
switch region.Reference
    case 'Bottom'
        idx_rem_y = ( y_mat<=-p.Results.vertExtend(2) | y_mat>=-p.Results.vertExtend(1) | isinf(y_mat));
    case 'Line'
        idx_rem_y = ( y_mat<=-p.Results.vertExtend(2) | y_mat>= p.Results.vertExtend(2) ) | isinf(y_mat);
    otherwise
        idx_rem_y = ( y_mat>= p.Results.vertExtend(2) | y_mat<= p.Results.vertExtend(1) );
end

% adding those to mask
Mask_reg(idx_rem_y) = false;

% mask region and bottom
Mask_reg_min_bot = Mask_reg & ~below_bot_mask;


%% cell work

% get cell width and height
cell_w = region.Cell_w;
cell_h = region.Cell_h;

% column index of cells composing the region. Note that reference is
% beggining of echogram so that if data starts at ping #11 in the file
% while cell width is 10 pings, then first cell of the region is cell #2
x_mat_idx = floor((x_mat-nanmin(x_mat(:)))/cell_w)+1;

% column index of cell in the region
slice_idx = floor((x-nanmin(x(:)))/cell_w)+1;

% row index of cells composing the region
y_mat_idx = floor((y_mat-nanmin(y_mat(:)))/cell_h)+1;


x_vec=nanmin(x_mat_idx(:)):nanmax(x_mat_idx(:));
idx_x_empty=setdiff(x_vec,unique(x_mat_idx));


%% INTEGRATION CALCULATIONS

% get s_v in linear values and remove total region and bottom mask
Sv_reg_lin = 10.^(Sv_reg/10);
Sv_reg_lin(~Mask_reg_min_bot) = nan;
Sv_reg(~Mask_reg_min_bot) = nan;

% number of cells in x and y
N_x = max(x_mat_idx(:));
N_y = max(y_mat_idx(:));

% total number of valid samples in each cell
output.nb_samples = accumarray( [y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)] , Mask_reg_min_bot(Mask_reg_min_bot) , [N_y N_x] , @sum , 0 );

% cells empty of valid samples:
Mask_reg_sub = (output.nb_samples==0);

% s_a as the sum of the s_v of valid samples within each cell, multiplied
% by the average between-sample range
eint_sparse = accumarray( [y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)] , Sv_reg_lin(Mask_reg_min_bot) , size(Mask_reg_sub) , @sum , 0 ) * dr;
output.eint = eint_sparse;
output.Sv_dB_std = accumarray( [y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)] , Sv_reg(Mask_reg_min_bot) , size(Mask_reg_sub) , @std , 0 );

idx_mat=repmat((1:size(y_mat_idx,1))',1,size(y_mat_idx,2));

idx_s_min = accumarray( [y_mat_idx(:) x_mat_idx(:)] ,idx_mat(:), [N_y N_x] , @min , nan);
idx_s_max = accumarray( [y_mat_idx(:) x_mat_idx(:)] ,idx_mat(:), [N_y N_x] , @max , nan);
idx_mask=(isnan(idx_s_max));
idx_s_min(idx_mask)=[];
idx_s_max(idx_mask)=[];

output.Vert_Slice_Idx = accumarray( x_mat_idx(1,:)' , slice_idx(:) , [N_x 1] , @min , 0)';
output.Horz_Slice_Idx = accumarray( [y_mat_idx(:) x_mat_idx(:)] ,y_mat_idx(:), [N_y N_x] , @nanmin , 0);

% first and last ping in each cell
output.Ping_S    = accumarray( x_mat_idx(1,:)' , sub_pings(:) , [N_x 1] , @min , nan)';
output.Ping_E    = accumarray( x_mat_idx(1,:)' , sub_pings(:) , [N_x 1] , @max , nan)';

% number of pings not flagged as bad transmits, in each cell
output.Nb_good_pings = repmat(accumarray(x_mat_idx(1,:)',(bad_trans_vec(:))==0,[N_x 1],@nansum,0),1,N_y)';

% first and last sample in each cell
output.Sample_S=nan(N_y,N_x);
output.Sample_E=nan(N_y,N_x);

output.Sample_S(~idx_mask)=sub_samples(idx_s_min);
output.Sample_E(~idx_mask)=sub_samples(idx_s_max);

% minimum and maximum depth of samples in each cell
output.Layer_depth_min=nan(N_y,N_x);
output.Layer_depth_min(~idx_mask)=sub_r(idx_s_min);
 
output.Layer_depth_max=nan(N_y,N_x);
output.Layer_depth_max(~idx_mask)=sub_r(idx_s_max)+dr;

% average depth of each cell
output.Depth_mean = (output.Layer_depth_min+output.Layer_depth_max)/2;

% minimum and maximum range of samples in each cell (referenced to the surface, bottom or line)

output.Range_ref_min = accumarray([y_mat_idx(:) x_mat_idx(:)],y_mat(:),size(Mask_reg_sub),@min,nan);
output.Range_ref_max = accumarray([y_mat_idx(:) x_mat_idx(:)],y_mat(:),size(Mask_reg_sub),@max,nan);

switch lower(region.Cell_h_unit)
    case 'samples'
        output.Range_ref_min = output.Range_ref_min*dr;
        output.Range_ref_max = output.Range_ref_max*dr;
end
output.Range_ref_max = output.Range_ref_max+dr;
% "thickness" (height of each cell)
output.Thickness_tot = abs(output.Range_ref_max-output.Range_ref_min);
output.Thickness_mean = (output.nb_samples)./output.Nb_good_pings*dr;

output.Dist_S = accumarray(x_mat_idx(1,:)',sub_dist(:),[N_x 1],@nanmin,nan)';
output.Dist_E = accumarray(x_mat_idx(1,:)',sub_dist(:),[N_x 1],@nanmax,nan)';

output.Time_S = accumarray(x_mat_idx(1,:)',sub_time(:),[N_x 1],@nanmin,nan)';
output.Time_E = accumarray(x_mat_idx(1,:)',sub_time(:),[N_x 1],@nanmax,nan)';

output.Lat_S = accumarray(x_mat_idx(1,:)',sub_lat(:),[N_x 1],@nanmin,nan)';
output.Lon_S = accumarray(x_mat_idx(1,:)',sub_lon(:),[N_x 1],@nanmin,nan)';

output.Lat_E = accumarray(x_mat_idx(1,:)',sub_lat(:),[N_x 1],@nanmax,nan)';
output.Lon_E = accumarray(x_mat_idx(1,:)',sub_lon(:),[N_x 1],@nanmax,nan)';

output.Sv_mean_lin = eint_sparse./(output.Nb_good_pings.*output.Thickness_mean);
% output.Sv_mean_lin      = eint_sparse./output.nb_samples/dr;
% output.Sv_mean_lin(output.nb_samples==0)=0;

output.PRC = output.nb_samples*dr./(output.Nb_good_pings.*output.Thickness_tot);

output.ABC = output.Thickness_mean.*output.Sv_mean_lin;
output.NASC = 4*pi*1852^2*output.ABC;
output.Lon_S(output.Lon_S>180) = output.Lon_S(output.Lon_S>180)-360;

%remove empty vertical slices (no data in those)
fields = fieldnames(output);
for ifi = 1:length(fields)
    output.(fields{ifi})(:,idx_x_empty) = [];
end

if p.Results.keep_all==0
    [N_y,N_x]=size(output.Sv_mean_lin);
    
    idx_rem = [];
    
    idx_zeros_start =  find(nansum(output.Sv_mean_lin,2)>0,1);
    
    if idx_zeros_start>1
        idx_rem = union(idx_rem,1:idx_zeros_start-1);
    end
    
    idx_zeros_end = find(flipud(nansum(output.Sv_mean_lin,2)>0),1);
    if idx_zeros_end>1
        idx_rem = union(idx_rem,N_y-((1:idx_zeros_end-1)-1));
    end
    
    for ifi = 1:length(fields)
        if size(output.(fields{ifi}),1) == N_y
            output.(fields{ifi})(idx_rem,:) = [];
        end
    end
    
    idx_rem = [];
    idx_zeros_start = find(nansum(output.Sv_mean_lin,1)>0,1);
    if idx_zeros_start>1
        idx_rem = union(idx_rem,1:idx_zeros_start-1);
    end
    
    idx_zeros_end = find(fliplr(nansum(output.Sv_mean_lin,2)>0),1);
    if idx_zeros_end>1
        idx_rem = union(idx_rem,N_x-((1:idx_zeros_end-1)-1));
    end
    
    for ifi = 1:length(fields)
        output.(fields{ifi})(:,idx_rem) = [];
    end
end

end
