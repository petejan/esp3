%% integrate_region_v5.m
%
% Integrate echogram
%
%% Help
%
% *USE*
%
% sub_output = integrate_region_v2(trans_obj,region) integrates acoustic data
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
% *sub_output VARIABLES*
%
% * |sub_output|: TODO: write description and info on variable
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
function output = integrate_region_v5(trans_obj,region,varargin)

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
addParameter(p,'block_len',1e7,@(x) x>0);
addParameter(p,'load_bar_comp',[]);

parse(p,trans_obj,region,varargin{:});

if any([region.Cell_h region.Cell_w]==0)
    warning('Region %.0f defined with cell size =0',region.ID);
    output=[];
    return;
end

time_tot=trans_obj.get_transceiver_time(region.Idx_pings);
pings_tot=trans_obj.get_transceiver_pings(region.Idx_pings);
output=[];

%% creating line_obj
if isempty(p.Results.line_obj)
    line_obj=line_cl('Range',zeros(size(time_tot)),'Time',time_tot);
else
    line_obj=p.Results.line_obj;
end

if p.Results.denoised>0
    field='svdenoised';
    if ~ismember('svdenoised',trans_obj.Data.Fieldname)
        field='sv';
    end
else
    field='sv';
end

idx_in=find(time_tot>=p.Results.horiExtend(1)&time_tot<=p.Results.horiExtend(2));

if isempty(idx_in)
    return;
end
idx_pings_tot=region.Idx_pings(idx_in);
pings_tot=pings_tot(idx_in);
time_tot=time_tot(idx_in);


if isempty(trans_obj.GPSDataPing.Dist)
    region.Cell_w_unit = 'pings';   
else
    dist_tot = trans_obj.GPSDataPing.Dist(idx_in);
end

switch region.Cell_w_unit
    case 'pings'
        x_tot = pings_tot;
    case 'meters'
        x_tot = dist_tot;
    case 'seconds'
        x_tot= time_tot*24*60*60;
end

idx_tot_idx = floor((x_tot-nanmin(x_tot(:)))/region.Cell_w)+1;

[~,idx_start]=unique(idx_tot_idx,'first');
[~,idx_end]=unique(idx_tot_idx,'last');

N_x_tot=numel(idx_start);

nb_pings_per_slices=idx_end-idx_start+1;


%
idx_r_tot=region.Idx_r;
range_tot=trans_obj.get_transceiver_range(idx_r_tot);
samples_tot=trans_obj.Data.get_samples(idx_r_tot);
% taking the average of distance between two samples
dr = mean(diff(range_tot));

% range and sample counter for reference line
line_r_ori = line_obj.Range;
line_t     = line_obj.Time;
line_r = resample_data_v2(line_r_ori,line_t,time_tot);
line_samples = round(line_r/dr);

% selecting the appropriate unit
switch region.Cell_h_unit
    case 'samples'
        y_tot =trans_obj.Data.get_samples(idx_r_tot);
        bot_int_tot = trans_obj.get_bottom_idx(idx_pings_tot);
        line_int_tot = line_samples;
    case 'meters'
        y_tot =range_tot;
        bot_int_tot = trans_obj.get_bottom_range(idx_pings_tot);
        line_int_tot = line_r;
end
bot_int_tot(isnan(bot_int_tot)) = inf;

switch region.Reference
    case 'Surface'
        line_ref_tot = zeros(size(bot_int_tot));
    case 'Bottom'
        line_ref_tot = bot_int_tot;
    case 'Line'
        line_ref_tot = line_int_tot;
end

block_size=nanmin(ceil(p.Results.block_len/numel(idx_r_tot)),numel(x_tot));
dslice=nanmin(ceil(block_size/nanmean(nb_pings_per_slices)),N_x_tot);
idx_ite_x=unique([dslice:dslice:N_x_tot N_x_tot]);


N_y_tot=ceil((range(y_tot)+range(line_ref_tot(~isinf(line_ref_tot))))/region.Cell_h);

y0=(nanmin(y_tot(:))-nanmax(line_ref_tot(~isinf(line_ref_tot))));
x0=nanmin(x_tot);
idx_x_empty=[];

load_bar_comp=p.Results.load_bar_comp;
if ~isempty(load_bar_comp)
    load_bar_comp.status_bar.setText(sprintf('Integrating %s',region.print()));
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(idx_ite_x), 'Value',0);
end
ub=0;
for ui=idx_ite_x

    is=idx_start(ui-dslice+1);
    ie=idx_end(ui);
    
    %% getting Sv
    [Sv_reg,idx_r,idx_pings,bad_data_mask,bad_trans_vec,intersection_mask,below_bot_mask,mask_from_st]=get_data_from_region(trans_obj,region,...
        'field',field,...
        'vertExtend',p.Results.vertExtend,...
        'horiExtend',[time_tot(is) time_tot(ie)],...
        'intersect_only',p.Results.intersect_only,...
        'idx_regs',p.Results.idx_regs,...
        'regs',p.Results.regs,...
        'select_reg',p.Results.select_reg,...
        'keep_bottom',p.Results.keep_bottom,...
        'keep_all',p.Results.keep_all);
    
    if isempty(Sv_reg)
        continue;
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
    
    [~,sub_idx_pings]=intersect(idx_pings_tot,idx_pings);
    [~,sub_idx_r]=intersect(idx_r_tot,idx_r);
    
    %% vectors in pings and samples
    
    % time, range, ping counter, and sample counter vectors
    sub_time = time_tot(sub_idx_pings);
    sub_pings = pings_tot(sub_idx_pings);
    sub_samples = samples_tot(sub_idx_r);
    sub_r=range_tot(sub_idx_r);
    
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
    
    y = y_tot(sub_idx_r);
    x = x_tot(sub_idx_pings);
    
    
    % meshgrid the vectors in X and Y
    [x_mat,y_mat] = meshgrid(x,y);
    
    line_ref=line_ref_tot(sub_idx_pings);
    [line_mat,~] = meshgrid(line_ref,idx_r_tot);
    line_mat(isnan(line_mat)) = 0;
    
    % offseting Y using the reference line
    y_mat = y_mat - line_mat;
    
    % identifying which samples are beyond the range imposed by vertExtend
    switch region.Reference
        case {'Bottom' 'Line'}
            idx_rem_y = ( y_mat<=-p.Results.vertExtend(2) | y_mat>=-p.Results.vertExtend(1) | isinf(y_mat));
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
    x_mat_idx = floor((x_mat-x0)/cell_w)+1;
    x_vec=nanmin(x_mat_idx(:)):nanmax(x_mat_idx(:));
    idx_x_empty=union(idx_x_empty ,setdiff(x_vec,unique(x_mat_idx)));
    
    ix1=nanmin(x_mat_idx(:));
    % column index of cell in the region
    slice_idx = floor((x-x0)/cell_w)+1;
    x_mat_idx=x_mat_idx-ix1+1;
    
    
    % row index of cells composing the region
    y_mat_idx = floor((y_mat-y0)/cell_h)+1;
    iy1=nanmin(y_mat_idx(~isinf(y_mat)));
    y_mat_idx=y_mat_idx-iy1+1;
    y_mat_idx(isinf(y_mat_idx))=size(y_mat_idx,1);
    
    %% INTEGRATION CALCULATIONS
    
    % get s_v in linear values and remove total region and bottom mask
    Sv_reg_lin = 10.^(Sv_reg/10);
    Sv_reg_lin(~Mask_reg_min_bot) = nan;
    Sv_reg(~Mask_reg_min_bot) = nan;
    
    % number of cells in x and y
    N_x = max(x_mat_idx(:));
    N_y = max(y_mat_idx(:));
    
    % total number of valid samples in each cell
    sub_output.nb_samples = accumarray( [y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)] , Mask_reg_min_bot(Mask_reg_min_bot) , [N_y N_x] , @sum , 0 );
    
    % cells empty of valid samples:
    Mask_reg_sub = (sub_output.nb_samples==0);
    
    % s_a as the sum of the s_v of valid samples within each cell, multiplied
    % by the average between-sample range
    eint_sparse = accumarray( [y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)] , Sv_reg_lin(Mask_reg_min_bot) , size(Mask_reg_sub) , @sum , 0 ) * dr;
    sub_output.eint = eint_sparse;
    sub_output.Sv_dB_std = accumarray( [y_mat_idx(Mask_reg_min_bot) x_mat_idx(Mask_reg_min_bot)] , Sv_reg(Mask_reg_min_bot) , size(Mask_reg_sub) , @std , 0 );
    
    idx_mat=repmat((1:size(y_mat_idx,1))',1,size(y_mat_idx,2));
    
    idx_s_min = accumarray( [y_mat_idx(:) x_mat_idx(:)] ,idx_mat(:), [N_y N_x] , @min , nan);
    idx_s_max = accumarray( [y_mat_idx(:) x_mat_idx(:)] ,idx_mat(:), [N_y N_x] , @max , nan);
    
    idx_mask=(isnan(idx_s_max));
    idx_s_min(idx_mask)=[];
    idx_s_max(idx_mask)=[];
    
    sub_output.Vert_Slice_Idx = accumarray( x_mat_idx(1,:)' , slice_idx(:) , [N_x 1] , @min , 0)';
    sub_output.Horz_Slice_Idx = accumarray( [y_mat_idx(:) x_mat_idx(:)] ,y_mat_idx(:)+iy1-1, [N_y N_x] , @nanmin , 0);
    
    % first and last ping in each cell
    sub_output.Ping_S    = accumarray( x_mat_idx(1,:)' , sub_pings(:) , [N_x 1] , @min , nan)';
    sub_output.Ping_E    = accumarray( x_mat_idx(1,:)' , sub_pings(:) , [N_x 1] , @max , nan)';
    
    % number of pings not flagged as bad transmits, in each cell
    sub_output.Nb_good_pings = repmat(accumarray(x_mat_idx(1,:)',(bad_trans_vec(:))==0,[N_x 1],@nansum,0),1,N_y)';
    
    % first and last sample in each cell
    sub_output.Sample_S=nan(N_y,N_x);
    sub_output.Sample_E=nan(N_y,N_x);
    
    sub_output.Sample_S(~idx_mask)=sub_samples(idx_s_min);
    sub_output.Sample_E(~idx_mask)=sub_samples(idx_s_max);
    
    % minimum and maximum depth of samples in each cell
    sub_output.Layer_depth_min=nan(N_y,N_x);
    sub_output.Layer_depth_min(~idx_mask)=sub_r(idx_s_min);
    
    sub_output.Layer_depth_max=nan(N_y,N_x);
    sub_output.Layer_depth_max(~idx_mask)=sub_r(idx_s_max)+dr;
    
    % average depth of each cell
    sub_output.Depth_mean = (sub_output.Layer_depth_min+sub_output.Layer_depth_max)/2;
    
    % minimum and maximum range of samples in each cell (referenced to the surface, bottom or line)
    
    switch region.Reference
        case 'Surface'
            sub_output.Range_ref_min =  sub_output.Layer_depth_min;
            sub_output.Range_ref_max = sub_output.Layer_depth_max;
        otherwise
            sub_output.Range_ref_min = accumarray([y_mat_idx(:) x_mat_idx(:)],y_mat(:),size(Mask_reg_sub),@min,nan);
            sub_output.Range_ref_max = accumarray([y_mat_idx(:) x_mat_idx(:)],y_mat(:),size(Mask_reg_sub),@max,nan);
            
            switch lower(region.Cell_h_unit)
                case 'samples'
                    sub_output.Range_ref_min = sub_output.Range_ref_min*dr;
                    sub_output.Range_ref_max = sub_output.Range_ref_max*dr;
            end
    end
    
    sub_output.Range_ref_max = sub_output.Range_ref_max+dr;
    % "thickness" (height of each cell)
    sub_output.Thickness_tot = abs(sub_output.Range_ref_max-sub_output.Range_ref_min);
    sub_output.Thickness_mean = (sub_output.nb_samples)./sub_output.Nb_good_pings*dr;
    
    sub_output.Dist_S = accumarray(x_mat_idx(1,:)',sub_dist(:),[N_x 1],@nanmin,nan)';
    sub_output.Dist_E = accumarray(x_mat_idx(1,:)',sub_dist(:),[N_x 1],@nanmax,nan)';
    
    sub_output.Time_S = accumarray(x_mat_idx(1,:)',sub_time(:),[N_x 1],@nanmin,nan)';
    sub_output.Time_E = accumarray(x_mat_idx(1,:)',sub_time(:),[N_x 1],@nanmax,nan)';
    
    sub_output.Lat_S = accumarray(x_mat_idx(1,:)',sub_lat(:),[N_x 1],@nanmin,nan)';
    sub_output.Lon_S = accumarray(x_mat_idx(1,:)',sub_lon(:),[N_x 1],@nanmin,nan)';
    
    sub_output.Lat_E = accumarray(x_mat_idx(1,:)',sub_lat(:),[N_x 1],@nanmax,nan)';
    sub_output.Lon_E = accumarray(x_mat_idx(1,:)',sub_lon(:),[N_x 1],@nanmax,nan)';
    
    sub_output.Sv_mean_lin = eint_sparse./(sub_output.Nb_good_pings.*sub_output.Thickness_mean);
    % sub_output.Sv_mean_lin      = eint_sparse./sub_output.nb_samples/dr;
    % sub_output.Sv_mean_lin(sub_output.nb_samples==0)=0;
    
    sub_output.PRC = sub_output.nb_samples*dr./(sub_output.Nb_good_pings.*sub_output.Thickness_tot);
    
    sub_output.ABC = sub_output.Thickness_mean.*sub_output.Sv_mean_lin;
    sub_output.NASC = 4*pi*1852^2*sub_output.ABC;
    sub_output.Lon_S(sub_output.Lon_S>180) = sub_output.Lon_S(sub_output.Lon_S>180)-360;
    
    if ui==idx_ite_x(1)
        output=init_ouput(N_y_tot,N_x_tot,sub_output);
    end
    output=complete_ouput(output,sub_output,iy1,ix1);
    if ~isempty(load_bar_comp)
        ub=ub+1;
        set(load_bar_comp.progress_bar, 'Value',ub);
    end
end
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

function output=init_ouput(N_y_tot,N_x_tot,sub_output)
fields = fieldnames(sub_output);
for ifi=1:numel(fields)
    if all(size(sub_output.(fields{ifi}))>1)
        output.(fields{ifi})=nan(N_y_tot,N_x_tot);
    elseif size(sub_output.(fields{ifi}),1)==1  
        output.(fields{ifi})=nan(1,N_x_tot);
    elseif size(sub_output.(fields{ifi}),2)==1
        output.(fields{ifi})=nan(N_y_tot,1);
    end
end
end

function output=complete_ouput(output,sub_output,y1,x1)
fields = fieldnames(sub_output);
[N_y,N_x]=size(sub_output.nb_samples);
for ifi=1:numel(fields)
    if all(size(sub_output.(fields{ifi}))==[N_y,N_x])
        output.(fields{ifi})(y1:(y1+N_y-1),x1:(x1+N_x-1))=sub_output.(fields{ifi});
    elseif size(sub_output.(fields{ifi}),1)==1&&size(sub_output.(fields{ifi}),2)==N_x        
        output.(fields{ifi})(x1:(x1+N_x-1))=sub_output.(fields{ifi});
    elseif size(sub_output.(fields{ifi}),2)==1&&size(sub_output.(fields{ifi}),1)==N_y
        output.(fields{ifi})(y1:(y1+N_y-1))=sub_output.(fields{ifi});
    end
end
end
