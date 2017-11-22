%% integrate_region_v3.m
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
function output = integrate_region_v3(trans_obj,region,varargin)

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
    field='sv_denoised';
    if ~ismember('svdenoised',trans_bj.Data.Fieldnames)
        disp('Cannot find denoised Sv, integrating normal Sv.')
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
    'select_reg',p.Results.select_reg,...
    'keep_bottom',p.Results.keep_bottom,...
    'keep_all',p.Results.keep_all);

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
sub_r = trans_obj.get_transceiver_range(idx_r);
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
[~,sub_r_mat] = meshgrid(bot_int,sub_r);
[~,sub_samples_mat] = meshgrid(bot_int,sub_samples);


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
x_mat_idx = ceil(x_mat/cell_w);

% column index of cell in the region
slice_idx = ceil(x/cell_w);
slice_idx = slice_idx-slice_idx(1)+1;

% row index of cells composing the region
switch region.Reference
    case {'Bottom' 'Line'}
        y_mat_idx = floor(y_mat/cell_h)+1;
    otherwise
        y_mat_idx = ceil(y_mat/cell_h);
end

% row and column index of top left cell in the region
y0 = min(y_mat_idx(~isinf(y_mat_idx)));
x0 = min(x_mat_idx(:));

% bringing back to 1
y_mat_idx = y_mat_idx-y0+1;
x_mat_idx = x_mat_idx-x0+1;


%% INTEGRATION CALCULATIONS

% get s_v in linear values and remove total region and bottom mask
Sv_reg_lin = 10.^(Sv_reg/10);
Sv_reg_lin(~Mask_reg_min_bot) = nan;

% number of cells in x and y
N_x = max(x_mat_idx(:));
N_y = max(y_mat_idx(:));

% total number of valid samples in each cell
output.nb_samples = accumarray( [y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)] , Mask_reg_min_bot(Mask_reg_min_bot) , [N_y N_x] , @sum , 0 );

% cells empty of valid samples:
Mask_reg_sub = (output.nb_samples==0);
output.nb_samples(Mask_reg_sub) = NaN;

% s_a as the sum of the s_v of valid samples within each cell, multiplied
% by the average between-sample range
eint_sparse = accumarray( [y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)] , Sv_reg_lin(Mask_reg_min_bot) , size(Mask_reg_sub) , @sum , 0 ) * dr;
output.eint = eint_sparse;

output.Slice_Idx = accumarray( x_mat_idx(1,:)' , slice_idx(:) , [N_x 1] , @nanmin , NaN)';

% first and last ping in each cell
output.Ping_S    = accumarray( x_mat_idx(1,:)' , sub_pings(:) , [N_x 1] , @nanmin , NaN)';
output.Ping_E    = accumarray( x_mat_idx(1,:)' , sub_pings(:) , [N_x 1] , @nanmax , NaN)';

% number of pings not flagged as bad transmits, in each cell
output.Nb_good_pings = repmat(accumarray(x_mat_idx(1,:)',(bad_trans_vec(:))==0,[N_x 1],@nansum,0),1,N_y)';
output.Nb_good_pings_esp2 = output.Nb_good_pings;
output.Nb_good_pings_esp2(Mask_reg_sub) = NaN;

% first and last sample in each cell
output.Sample_S = accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],sub_samples_mat(Mask_reg),size(Mask_reg_sub),@min,NaN);
output.Sample_E = accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],sub_samples_mat(Mask_reg),size(Mask_reg_sub),@max,NaN);

% "thickness" (height of each cell)
output.Thickness_tot = ( output.Sample_E - output.Sample_S + 1 )*dr;
output.Thickness_tot(Mask_reg_sub) = NaN;

% minimum and maximum depth of samples in each cell
output.Layer_depth_min = accumarray([y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)],sub_r_mat(Mask_reg_min_bot),size(Mask_reg_sub),@min,NaN);
output.Layer_depth_max = accumarray([y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)],sub_r_mat(Mask_reg_min_bot),size(Mask_reg_sub),@max,NaN);

% average depth of each cell
output.Range_mean = (output.Layer_depth_min+output.Layer_depth_max)/2;
output.Range_mean(Mask_reg_sub) = NaN;

% ?
switch region.Cell_h_unit
    case 'samples'
        output.Range_ref_min = accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],y_mat(Mask_reg),size(Mask_reg_sub),@min,NaN)*dr;
        output.Range_ref_max = accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],y_mat(Mask_reg),size(Mask_reg_sub),@max,NaN)*dr;
        output.Range_ref_min(Mask_reg_sub) = NaN;
        output.Range_ref_max(Mask_reg_sub) = NaN;
    case 'meters'
        output.Range_ref_min = accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],y_mat(Mask_reg),size(Mask_reg_sub),@min,NaN);
        output.Range_ref_max = accumarray([y_mat_idx(Mask_reg) x_mat_idx(Mask_reg)],y_mat(Mask_reg),size(Mask_reg_sub),@max,NaN);
        output.Range_ref_min(Mask_reg_sub) = NaN;
        output.Range_ref_max(Mask_reg_sub) = NaN;
end

output.Thickness_mean = (output.nb_samples)./output.Nb_good_pings*dr;
output.Thickness_mean(Mask_reg_sub) = NaN;

output.Dist_S = accumarray(x_mat_idx(1,:)',sub_dist(:),[N_x 1],@nanmin,nan)';
output.Dist_E = accumarray(x_mat_idx(1,:)',sub_dist(:),[N_x 1],@nanmax,nan)';

output.Time_S = accumarray(x_mat_idx(1,:)',sub_time(:),[N_x 1],@nanmin,0)';
output.Time_E = accumarray(x_mat_idx(1,:)',sub_time(:),[N_x 1],@nanmax,0)';

output.Lat_S = accumarray(x_mat_idx(1,:)',sub_lat(:),[N_x 1],@nanmin,nan)';
output.Lon_S = accumarray(x_mat_idx(1,:)',sub_lon(:),[N_x 1],@nanmin,nan)';

output.Lat_E = accumarray(x_mat_idx(1,:)',sub_lat(:),[N_x 1],@nanmax,nan)';
output.Lon_E = accumarray(x_mat_idx(1,:)',sub_lon(:),[N_x 1],@nanmax,nan)';

output.Sv_mean_lin_esp2 = eint_sparse./(output.Nb_good_pings_esp2.*output.Thickness_tot);
output.Sv_mean_lin      = eint_sparse./output.nb_samples/dr;

output.PRC = output.nb_samples*dr./(output.Nb_good_pings.*output.Thickness_tot);

idx_nan = (output.Sv_mean_lin_esp2==0);
output.Sv_mean_lin_esp2(idx_nan) = nan;

output.ABC = output.Thickness_mean.*output.Sv_mean_lin;
output.NASC = 4*pi*1852^2*output.ABC;
output.Lon_S(output.Lon_S>180) = output.Lon_S(output.Lon_S>180)-360;


if p.Results.keep_all==0
    
    fields = fieldnames(output);
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
