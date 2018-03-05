function [data,idx_r,idx_pings,bad_data_mask,bad_trans_vec,intersection_mask,below_bot_mask,mask_from_st]=get_data_from_region(trans_obj,region,varargin)
    
    %% input variables management through input parser
p = inputParser;

addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addRequired(p,'region',@(x) isa(x,'region_cl'));
addParameter(p,'vertExtend',[0 Inf],@isnumeric);
addParameter(p,'horiExtend',[0 Inf],@isnumeric);
addParameter(p,'field','sv',@ischar);
addParameter(p,'intersect_only',0,@isnumeric);
addParameter(p,'idx_regs',[],@isnumeric);
addParameter(p,'regs',region_cl.empty(),@(x) isa(x,'region_cl'));
addParameter(p,'select_reg','all',@ischar);
addParameter(p,'keep_bottom',0,@isnumeric);
addParameter(p,'keep_all',0,@isnumeric);

parse(p,trans_obj,region,varargin{:});

data=[];
idx_r=[];
idx_pings=[];
bad_data_mask=[];
intersection_mask=[];
bad_trans_vec=[];
below_bot_mask=[];
mask_from_st=[];


idx_pings_tot=region.Idx_pings;


time=trans_obj.get_transceiver_time(idx_pings_tot);

idx_keep_x=(time<=p.Results.horiExtend(2)&time>=p.Results.horiExtend(1));
if ~any(idx_keep_x)
    return;
end
idx_pings=idx_pings_tot(idx_keep_x);
idx_r=region.Idx_r;
% tic
% [ping_mat,r_mat]=meshgrid(idx_pings,idx_r);
% isin=arrayfun(@(x,y) isinterior(region.Poly,x,y),ping_mat,r_mat);
% toc
% figure();imagesc(isin)
% tic
% isin_2=region.Poly.isinterior(ping_mat(:),r_mat(:));
% isin_2=reshape(isin,size(ping_mat));
% toc
data=trans_obj.Data.get_subdatamat(idx_r,idx_pings,'field',p.Results.field);

bot_sple=trans_obj.get_bottom_idx(idx_pings);
bot_sple(isnan(bot_sple))=inf;

idx_keep_r=1:numel(idx_r);

if isempty(data)
    warning('No such data');
    return;
end


region.Idx_pings=idx_pings;
region.Idx_r=idx_r;

switch region.Shape
    case 'Polygon'
        region.MaskReg=region.get_sub_mask(idx_keep_r,idx_keep_x);
        data(region.get_mask==0)=NaN;
end

if isempty(idx_r)||isempty(idx_pings)
    warning('Cannot integrate this region, no data...');
    trans_obj.rm_region_id(region.Unique_ID);
    return;
end


if p.Results.intersect_only==1
    switch p.Results.select_reg
        case 'all'
            idx=trans_obj.find_regions_type('Data');
        otherwise
            idx=p.Results.idx_regs;
    end
    intersection_mask=region.get_mask_from_intersection(trans_obj.Regions(idx));
    if ~isempty(p.Results.regs)
        intersection_mask_2=region.get_mask_from_intersection(p.Results.regs);
        intersection_mask=intersection_mask_2|intersection_mask;
    end
else
   intersection_mask=true(size(data)); 
end

idx=trans_obj.find_regions_type('Bad Data');
bad_data_mask=region.get_mask_from_intersection(trans_obj.Regions(idx));

if region.Remove_ST
    mask_from_st=trans_obj.mask_from_st();
    mask_from_st=mask_from_st(idx_r,idx_pings);
else
    mask_from_st=false(size(data)); 
end

bad_trans_vec=(trans_obj.Bottom.Tag(idx_pings)==0);

if p.Results.keep_bottom==0
    below_bot_mask=bsxfun(@ge,idx_r(:),bot_sple(:)');
else
    below_bot_mask=false(size(data));
end


