function [output_2D_surf,output_2D_bot,regs,regCellInt,output_2D_sh,shadow_height_est,idx_freq_out_tot]=multi_freq_slice_transect2D(layer_obj,varargin)
p = inputParser;

addRequired(p,'layer_obj',@(layer_obj) isa(layer_obj,'layer_cl'));
addParameter(p,'idx_main_freq',1,@isnumeric);
addParameter(p,'idx_sec_freq',[],@isnumeric);
addParameter(p,'idx_regs',[],@isnumeric);
addParameter(p,'regs',region_cl.empty(),@(x) isa(x,'region_cl'));
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

parse(p,layer_obj,varargin{:});

regions_init=[p.Results.regs layer_obj.Transceivers(p.Results.idx_main_freq).Regions(p.Results.idx_regs)];


regs_out=cell(1,numel(regions_init));
idx_freq_out=cell(numel(regions_init),1);
r_factor=cell(1,numel(regions_init));
t_factor=cell(1,numel(regions_init));

for i=1:numel(regions_init)
    [regs_end,idx_freq_end,r_fac,t_fac]=layer_obj.generate_regions_for_other_freqs(p.Results.idx_main_freq,regions_init(i),p.Results.idx_sec_freq);
    regs=[regions_init(i) regs_end];
    r_fac=[i r_fac];
    t_fac=[1 t_fac];
    [idx_freq_out{i},is]=sort([p.Results.idx_main_freq,idx_freq_end]);
    regs_out{i}=regs(is);
    r_factor{i}=r_fac(is);
    t_factor{i}=t_fac(is);
end

idx_freq_out_tot=unique([idx_freq_out{:}]);

output_2D_surf=cell(1,numel(idx_freq_out_tot));
output_2D_bot=cell(1,numel(idx_freq_out_tot));
output_2D_sh=cell(1,numel(idx_freq_out_tot));
regCellInt=cell(1,numel(idx_freq_out_tot));
shadow_height_est=cell(1,numel(idx_freq_out_tot));
regs=cell(1,numel(idx_freq_out_tot));

for i_freq=1:numel(idx_freq_out_tot)
    idx_regs=cellfun(@(x) x==idx_freq_out_tot(i_freq) ,idx_freq_out,'un',0);
    regs_temp=[];
    t_fac=[];
    %r_fac=[];
    for ireg=1:numel(idx_regs)
        regs_temp=[regs_temp regs_out{ireg}(idx_regs{ireg})];
        t_fac=[t_fac t_factor{ireg}(idx_regs{ireg})];
        %r_fac=[r_fac r_factor{ireg}(idx_regs{ireg})];
    end
    
    switch p.Results.Slice_w_units
        case 'pings'
            cell_w=nanmax(floor(p.Results.Slice_w*nanmean(t_fac)),1);
        case 'meters'
            cell_w=p.Results.Slice_w;
    end

    trans_obj=layer_obj.Transceivers(idx_freq_out_tot(i_freq));
    [output_2D_surf{i_freq},output_2D_bot{i_freq},regs{i_freq},regCellInt{i_freq},output_2D_sh{i_freq},shadow_height_est{i_freq}]=trans_obj.slice_transect2D_new_int(...
        'regs',regs_temp,....
        'idx_regs',[],...
        'Slice_w',cell_w,...
        'Slice_w_units',p.Results.Slice_w_units,...
        'Slice_h',p.Results.Slice_h,...
        'StartTime',p.Results.StartTime,...
        'EndTime',p.Results.EndTime,...
        'Denoised',p.Results.Denoised,...
        'Motion_correction',p.Results.Motion_correction,...
        'Shadow_zone',p.Results.Shadow_zone,...
        'Shadow_zone_height',p.Results.Shadow_zone_height,...
        'DepthMin',p.Results.DepthMin,...
        'DepthMax',p.Results.DepthMax,...
        'RegInt',p.Results.RegInt,...
        'Remove_ST',p.Results.Remove_ST,...
        'intersect_only',p.Results.intersect_only);
    

end
