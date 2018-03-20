function [output_surf,output_bot,regs,regCellInt,output_shadow_reg,shadow_height_est]=slice_transect2D_new_int(trans_obj,varargin)

p = inputParser;


addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addParameter(p,'idx_regs',[],@isnumeric);
addParameter(p,'regs',region_cl.empty(),@(x) isa(x,'region_cl')|isempty(x));
addParameter(p,'Slice_w',50,@(x) x>0);
addParameter(p,'Slice_w_units','meters',@(unit) ~isempty(strcmp(unit,{'pings','meters'})));
addParameter(p,'Slice_h',10,@(x) x>0);
addParameter(p,'StartTime',0,@(x) x>=0);
addParameter(p,'EndTime',1,@(x) x>=0);
addParameter(p,'Denoised',0,@isnumeric);
addParameter(p,'Motion_correction',0,@isnumeric);
addParameter(p,'RegInt',0,@isnumeric);
addParameter(p,'Shadow_zone',0,@isnumeric);
addParameter(p,'Shadow_zone_height',10,@isnumeric);
addParameter(p,'DepthMin',0,@isnumeric);
addParameter(p,'DepthMax',Inf,@isnumeric);
addParameter(p,'intersect_only',1,@isnumeric);
addParameter(p,'Remove_ST',0,@isnumeric);
addParameter(p,'SliceInt',1,@isnumeric);
addParameter(p,'keep_all',0,@isnumeric);
addParameter(p,'keep_bottom',0,@isnumeric);
addParameter(p,'load_bar_comp',[]);
addParameter(p,'sv_thr',-999,@isnumeric);
parse(p,trans_obj,varargin{:});

Slice_w=p.Results.Slice_w;
Slice_w_units=p.Results.Slice_w_units;
Slice_h=p.Results.Slice_h;
idx_reg=p.Results.idx_regs;

idx_reg_bot=find_regions_ref(trans_obj,'Bottom');
idx_reg_surf=find_regions_ref(trans_obj,'Surface');

idx_reg_bot=intersect(idx_reg_bot,idx_reg);
idx_reg_surf=intersect(idx_reg_surf,idx_reg);

if ~isempty(p.Results.regs)
    regs_surf=p.Results.regs(strcmp({p.Results.regs(:).Reference},'Surface'));
    regs_bot=p.Results.regs(strcmp({p.Results.regs(:).Reference},'Bottom'));
else
    regs_surf=region_cl.empty();
    regs_bot=region_cl.empty;
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



if p.Results.SliceInt>0
    
    if (~isempty(idx_reg_surf)||~isempty(regs_surf)||p.Results.intersect_only==0||(isempty(regs_bot)&&isempty(idx_reg_bot)))
        reg_wc_surf=trans_obj.create_WC_region(...
            'y_min',0,...
            'y_max',Inf,...
            'Type','Data',...
            'Ref','Surface',...
            'Cell_w',Slice_w,...
            'Cell_h',Slice_h,...
            'Cell_w_unit',Slice_w_units,...
            'Cell_h_unit','meters',...
            'Remove_ST',p.Results.Remove_ST);
        
        if  ~isempty(reg_wc_surf)
            output_surf=trans_obj.integrate_region_v5(reg_wc_surf,'vertExtend',[p.Results.DepthMin p.Results.DepthMax],...
                'horiExtend',[st et],'idx_regs',idx_reg_surf,'regs',regs_surf,'select_reg','selected','intersect_only',p.Results.intersect_only,'denoised'...
                ,p.Results.Denoised,'motion_correction',p.Results.Motion_correction,'keep_all',1,'sv_thr',p.Results.sv_thr,'load_bar_comp',p.Results.load_bar_comp);
        else
            output_surf=[];
        end
    else
        output_surf=[];
    end
    
    if (~isempty(idx_reg_bot)||~isempty(regs_bot)||p.Results.intersect_only==0)
        reg_wc_bot=trans_obj.create_WC_region(...
            'y_min',0,...
            'y_max',Inf,...
            'Type','Data',...
            'Ref','Bottom',...
            'Cell_w',Slice_w,...
            'Cell_h',Slice_h,...
            'Cell_w_unit',Slice_w_units,...
            'Cell_h_unit','meters',...
            'Remove_ST',p.Results.Remove_ST);
        
        if ~isempty(reg_wc_bot)
            output_bot=trans_obj.integrate_region_v5(reg_wc_bot,'vertExtend',[p.Results.DepthMin p.Results.DepthMax],...
                'horiExtend',[st et],'idx_regs',idx_reg_bot,'regs',regs_bot,'select_reg','selected','intersect_only',p.Results.intersect_only,'denoised',...
                p.Results.Denoised,'motion_correction',p.Results.Motion_correction,'keep_all',1,'load_bar_comp',p.Results.load_bar_comp,'sv_thr',p.Results.sv_thr);
        else
            output_bot=[];
        end
    else
        output_bot=[];
    end
else
    output_bot=[];
    output_surf=[];
end
idx_reg_out=union(idx_reg_surf,idx_reg_bot);

regCellInt=cell(1,length(idx_reg_out)+numel(p.Results.regs));
regs=cell(1,length(idx_reg_out)+numel(p.Results.regs));

if p.Results.RegInt
    for i=1:length(idx_reg_out)
        regs{i}=trans_obj.Regions(idx_reg_out(i));
        regCellInt{i}=trans_obj.integrate_region_v5(trans_obj.Regions(idx_reg_out(i)),...
            'horiExtend',[st et],...
            'sv_thr',p.Results.sv_thr,...
            'denoised',p.Results.Denoised,'motion_correction',p.Results.Motion_correction,'load_bar_comp',p.Results.load_bar_comp,'keep_all',p.Results.keep_all,'keep_bottom',p.Results.keep_bottom);
    end
    for i=1:length(p.Results.regs)
        regs{i+length(idx_reg_out)}=p.Results.regs(i);
        regCellInt{i+length(idx_reg_out)}=trans_obj.integrate_region_v5(p.Results.regs(i),...
            'horiExtend',[st et],...
            'sv_thr',p.Results.sv_thr,...
            'denoised',p.Results.Denoised,'motion_correction',p.Results.Motion_correction,'load_bar_comp',p.Results.load_bar_comp,'keep_all',p.Results.keep_all,'keep_bottom',p.Results.keep_bottom);
    end
else
    regs=[];
    regCellInt={};
end

if(~isempty(idx_reg_out)||~isempty(p.Results.regs))&&p.Results.Shadow_zone>0
    [output_shadow_reg,~,shadow_height_est_temp]=trans_obj.estimate_shadow_zone('Shadow_zone_height',p.Results.Shadow_zone_height,...
        'StartTime',st,'EndTime',et,...
        'Slice_w',Slice_w,'Slice_units',Slice_w_units,...
        'Denoised',p.Results.Denoised,...
        'Motion_correction',p.Results.Motion_correction,...
        'idx_regs',idx_reg_out,...
        'sv_thr',p.Results.sv_thr,...
        'regs',p.Results.regs);
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