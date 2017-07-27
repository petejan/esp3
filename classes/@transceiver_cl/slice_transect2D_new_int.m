function [output_surf,output_bot,regs,regCellInt,output_shadow_reg,shadow_height_est]=slice_transect2D_new_int(trans_obj,varargin)

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

idx_reg=p.Results.idx_regs;

idx_reg_bot=find_regions_ref(trans_obj,'Bottom');
idx_reg_surf=find_regions_ref(trans_obj,'Surface');

idx_reg_bot=intersect(idx_reg_bot,idx_reg);
idx_reg_surf=intersect(idx_reg_surf,idx_reg);


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


output_surf=trans_obj.integrate_region_v2(reg_wc_surf,'horiExtend',[st et],'idx_regs',idx_reg_surf,'select_reg','selected','intersect_only',1,'denoised'...
    ,p.Results.Denoised,'motion_correction',p.Results.Motion_correction,'keep_all',1);

if ~isempty(idx_reg_bot)
    output_bot=trans_obj.integrate_region_v2(reg_wc_bot,'horiExtend',[st et],'idx_regs',idx_reg_bot,'select_reg','selected','intersect_only',1,'denoised',...
        p.Results.Denoised,'motion_correction',p.Results.Motion_correction,'keep_all',1);
else
    output_bot=[];
end

idx_reg_out=union(idx_reg_surf,idx_reg_bot);

regCellInt=cell(1,length(idx_reg_out));
regs=cell(1,length(idx_reg_out));


if p.Results.RegInt
    for i=1:length(idx_reg_out)
        regs{i}=trans_obj.Regions(idx_reg_out(i));
        regCellInt{i}=trans_obj.integrate_region_v2(trans_obj.Regions(idx_reg_out(i)),...
        'horiExtend',[st et],...
        'denoised',p.Results.Denoised,'motion_correction',p.Results.Motion_correction);
    end
else
    regs={};
    regCellInt={};
end

if~isempty(idx_reg_out)&&p.Results.Shadow_zone>0
    [output_shadow_reg,~,shadow_height_est_temp]=trans_obj.estimate_shadow_zone('Shadow_zone_height',p.Results.Shadow_zone_height,...
        'StartTime',st,'EndTime',et,...
        'Slice_w',Slice_w,'Slice_units',Slice_w_units,...
        'Denoised',p.Results.Denoised,...
        'Motion_correction',p.Results.Motion_correction,...
        'idx_regs',idx_reg_out);
    shadow_height_est=zeros(1,size(output_shadow_reg.eint,2));
    
    for k=1:length(shadow_height_est)
        if ~isnan(output_shadow_reg.Ping_S(k))
            shadow_height_est(k)=nanmean(shadow_height_est_temp(output_shadow_reg.Ping_S(k):output_shadow_reg.Ping_E(k)));
        end
    end
    
else
    output_shadow_reg=[];
    shadow_height_est=[];
end



end