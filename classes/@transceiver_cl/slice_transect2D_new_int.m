function [output_surf,output_bot,regs,regCellInt]=slice_transect2D_new_int(trans_obj,varargin)

p = inputParser;


addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addParameter(p,'idx_regs',[],@isnumeric);
addParameter(p,'Slice_w',50,@(x) x>0);
addParameter(p,'Slice_w_units','meters',@(unit) ~isempty(strcmp(unit,{'pings','meters'})));
addParameter(p,'Slice_h',10,@(x) x>0);
addParameter(p,'StartTime',0,@(x) x>0);
addParameter(p,'EndTime',1,@(x) x>0);
addParameter(p,'Denoised',0,@isnumeric);
addParameter(p,'Motion_correction',0,@isnumeric);
addParameter(p,'RegInt',0,@isnumeric);
addParameter(p,'Shadow_zone',0,@isnumeric);
addParameter(p,'Shadow_zone_height',10,@isnumeric);

parse(p,trans_obj,varargin{:});

Slice_w=p.Results.Slice_w;
Slice_w_units=p.Results.Slice_w_units;
Slice_h=p.Results.Slice_h;


if ~isempty(p.Results.idx_regs)
    idx_reg=trans_obj.find_regions_Unique_ID(p.Results.idx_regs);
else
    idx_reg=1:numel(trans_obj.Regions);
end

idx_reg_bot=find_regions_ref(trans_obj,'Bottom');
idx_reg_surf=find_regions_ref(trans_obj,'Surface');


if isempty(idx_reg_bot)
    output_bot=[];
end

if isempty(idx_reg_surf)
    output_surf=[];
end

if isempty(idx_reg_bot)&&isempty(idx_reg_surf)
    regs=[];
    regCellInt={};
    return;
end

if ~isempty(idx_reg)
    idx_reg_bot=intersect(idx_reg_bot,idx_reg);
    idx_reg_surf=intersect(idx_reg_surf,idx_reg);
end

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

reg_wc_surf=trans_obj.create_WC_region(...
    'y_min',0,...
    'y_max',Inf,...
    'Type','Data',...
    'Ref','Surface',...
    'Cell_w',Slice_w,...
    'Cell_h',Slice_h,...
    'Cell_w_unit',Slice_w_units,...
    'Cell_h_unit','meters');

reg_wc_bot=trans_obj.create_WC_region(...
    'y_min',0,...
    'y_max',Inf,...
    'Type','Data',...
    'Ref','Bottom',...
    'Cell_w',Slice_w,...
    'Cell_h',Slice_h,...
    'Cell_w_unit',Slice_w_units,...
    'Cell_h_unit','meters');

if ~isempty(idx_reg_surf)
    output_surf=trans_obj.integrate_region_v2(reg_wc_surf,'horiExtend',[st et],'idx_regs',idx_reg_surf,'intersect_only',1,'denoised'...
        ,p.Results.Denoised,'motion_correction',p.Results.Motion_correction);
end
if ~isempty(idx_reg_bot)
    output_bot=trans_obj.integrate_region_v2(reg_wc_bot,'horiExtend',[st et],'idx_regs',idx_reg_bot,'intersect_only',1,'denoised',...
        p.Results.Denoised,'motion_correction',p.Results.Motion_correction);
end
regCellInt=cell(1,length(idx_reg));


if p.Results.RegInt
    for i=1:length(idx_reg)
        regs(i)=trans_obj.Regions(idx_reg(i));
        regCellInt{i}=trans_obj.integrate_region_v2(trans_obj.Regions(idx_reg(i)));
    end
else
    regs=[];
    regCellInt={};
end

end