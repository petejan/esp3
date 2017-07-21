function [output,regCellInt]=slice_transect2D_new_int(trans_obj,varargin)

p = inputParser;


addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addParameter(p,'idx_regs',[],@isnumeric);
addParameter(p,'Slice_w',50,@(x) x>0);
addParameter(p,'Slice_w_units','meters',@(unit) ~isempty(strcmp(unit,{'pings','meters'})));
addParameter(p,'Slice_h',10,@(x) x>0);
addParameter(p,'StartTime',0,@(x) x>0);
addParameter(p,'EndTime',1,@(x) x>0);
addParameter(p,'Reference','Surface',@(ref) ~isempty(strcmpi(ref,{'Surface','Bottom'})));
addParameter(p,'Denoised',0,@isnumeric);
addParameter(p,'Motion_correction',0,@isnumeric);
addParameter(p,'RegInt',0,@isnumeric);

parse(p,trans_obj,varargin{:});

Slice_w=p.Results.Slice_w;
Slice_w_units=p.Results.Slice_w_units;
Slice_h=p.Results.Slice_h;


if ~isempty(p.Results.idx_regs)
    idx_reg=trans_obj.find_regions_Unique_ID(p.Results.idx_regs);
else
    idx_reg=1:numel(trans_obj.Regions);
end

idx_reg_2=find_regions_ref(trans_obj,p.Results.Reference);
if isempty(idx_reg_2)
    output=[];
    regCellInt={};
    return;
end

idx_reg=intersect(idx_reg_2,idx_reg);


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

reg_wc=trans_obj.create_WC_region(...
    'y_min',0,...
    'y_max',Inf,...
    'Type','Data',...
    'Ref',p.Results.Reference,...
    'Cell_w',Slice_w,...
    'Cell_h',Slice_h,...
    'Cell_w_unit',Slice_w_units,...
    'Cell_h_unit','meters');

output=trans_obj.integrate_region_v2(reg_wc,'horiExtend',[st et],'idx_regs',idx_reg,'intersect_only',1,'denoised',p.Results.Denoised,'motion_correction',p.Results.Motion_correction);
regCellInt=cell(1,length(idx_reg));

if p.Results.RegInt
    for i=1:length(idx_reg)
        regCellInt{i}=trans_obj.integrate_region_v2(trans_obj.Regions(idx_reg(i)));
    end
end

end