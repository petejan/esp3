function [output_2D_surf,output_2D_bot,regs,regCellInt,reg_descr_table,output_2D_sh,shadow_height_est,idx_freq_out_tot]=multi_freq_slice_transect2D(layer_obj,varargin)
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
    r_fac=[1 r_fac];
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

idx_main_freq=p.Results.idx_main_freq;
reg_descr_table=[];

idx_main=p.Results.idx_main_freq==idx_freq_out_tot;



if p.Results.RegInt
    for ireg=1:length(regs{idx_main})
        reg_descriptors=layer_obj.Transceivers(p.Results.idx_main_freq).get_region_descriptors(regs{idx_freq_out_tot==idx_main_freq}{ireg},'survey_data',layer_obj.get_survey_data());
        for ir=1:length(idx_freq_out_tot)
            output_reg=regCellInt{ir}{ireg};
            if ~isempty(output_reg)
                output_reg.Sv_mean_lin(output_reg.Sv_mean_lin==0)=nan;
                Sv_mean=pow2db_perso(nanmean(output_reg.Sv_mean_lin(:)));
                delta_sv=nanstd(pow2db_perso(output_reg.Sv_mean_lin(:)));
                reg_descriptors.(sprintf('Sv_%.0fkHz',layer_obj.Frequencies(idx_freq_out_tot(ir))/1e3))=Sv_mean;
                reg_descriptors.(sprintf('Delta_Sv_%.0fkHz',layer_obj.Frequencies(idx_freq_out_tot(ir))/1e3))=delta_sv;
            end
        end
        reg_descr_table = [reg_descr_table;struct2table(reg_descriptors,'asarray',1)];
    end
end

idx_freq_other=setdiff(idx_freq_out_tot,p.Results.idx_main_freq);

data_size_surf=size(output_2D_surf{idx_main}.nb_samples);
if ~isempty(output_2D_bot{idx_main})
    data_size_bot=size(output_2D_bot{idx_main}.nb_samples);
end
if ~isempty(output_2D_sh{idx_main})
    data_size_sh=size(output_2D_sh{idx_main}.nb_samples);
end
%figure();imagesc(pow2db_perso(output_2D_surf.Sv_mean_lin))
for ir=1:length(idx_freq_other)
    idx_sec=idx_freq_other(ir)==idx_freq_out_tot;
    output_2D_surf_sec=output_2D_surf{idx_sec};
    output_2D_sh_sec=output_2D_sh{idx_sec};
    output_2D_bot_sec=output_2D_bot{idx_sec};
    %shadow_height_est_sec=shadow_height_est{idx_sec};
    
    [mask_in,mask_out]=match_data(output_2D_surf_sec.Time_S,output_2D_surf_sec.Range_ref_min,output_2D_surf{idx_main}.Time_S,output_2D_surf{idx_main}.Range_ref_min);
    output_2D_surf{idx_main}.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))=zeros(data_size_surf);
    output_2D_surf{idx_main}.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))(mask_out)=output_2D_surf_sec.Sv_mean_lin(mask_in);
    output_2D_surf{idx_main}.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))=zeros(data_size_surf);
    output_2D_surf{idx_main}.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))(mask_out)=output_2D_surf_sec.Sv_dB_std(mask_in);
    output_2D_surf{idx_main}.(sprintf('PRC_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))=zeros(data_size_surf);
    output_2D_surf{idx_main}.(sprintf('PRC_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))(mask_out)=output_2D_surf_sec.PRC(mask_in);
    %figure();imagesc(pow2db_perso(output_2D_surf_sec.Sv_mean_lin));
    
    if ~isempty(output_2D_bot{idx_main})
        %figure();imagesc(pow2db_perso(output_2D_bot_sec.Sv_mean_lin));
        [mask_in,mask_out]=match_data(output_2D_bot_sec.Time_S,output_2D_bot_sec.Range_ref_min,output_2D_bot{idx_main}.Time_S,output_2D_bot{idx_main}.Range_ref_min);
        output_2D_bot{idx_main}.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))=zeros(data_size_bot);
        output_2D_bot{idx_main}.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))(mask_out)=output_2D_bot_sec.Sv_mean_lin(mask_in);
        output_2D_bot.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))=zeros(data_size_bot);
        output_2D_bot{idx_main}.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))(mask_out)=output_2D_bot_sec.Sv_dB_std(mask_in);
        output_2D_bot{idx_main}.(sprintf('PRC_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))=zeros(data_size_surf);
        output_2D_bot{idx_main}.(sprintf('PRC_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))(mask_out)=output_2D_bot_sec.PRC(mask_in);
    end
    
    if ~isempty(output_2D_sh{idx_main})
        [mask_in,mask_out]=match_data(output_2D_sh_sec.Time_S,output_2D_sh_sec.Range_ref_min,output_2D_sh{idx_main}.Time_S,output_2D_sh{idx_main}.Range_ref_min);
        output_2D_sh{idx_main}.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))=zeros(data_size_sh);
        output_2D_sh{idx_main}.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))(mask_out)=output_2D_sh_sec.Sv_mean_lin(mask_in);
        output_2D_sh{idx_main}.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))=zeros(data_size_sh);
        output_2D_sh{idx_main}.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))(mask_out)=output_2D_sh_sec.Sv_dB_std(mask_in);
        output_2D_sh{idx_main}.(sprintf('PRC_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))=zeros(data_size_surf);
        output_2D_sh{idx_main}.(sprintf('PRC_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))/1e3))(mask_out)=output_2D_sh_sec.PRC(mask_in);
    end
    
end
end
function [mask_in,mask_out]=match_data(t_in,r_in,t_out,r_out)
mask_in=zeros(size(r_in,1),size(t_in,2));
mask_out=zeros(size(r_out,1),size(t_out,2));
dt=gradient(t_out);
[~,dr] = gradient(r_out);
for j=1:size(t_out,2)
    [~,idx_t]=nanmin(abs(t_out(j)-t_in));
    if abs(t_in(idx_t)-t_out(j))>abs(dt(j))
        t_in(idx_t)=nan;
        r_in(:,idx_t)
        continue;
    end
    for i=1:size(r_out,1)
        [~,idx_r]=nanmin(abs(r_out(i,j)-r_in(:,idx_t)));
        if abs(r_in(idx_r,idx_t)-r_out(i,j))<=abs(dr(i,j))
            mask_out(i,j)=1;
            mask_in(idx_r,idx_t)=1;
        end
        r_in(idx_r,idx_t)=nan;
    end
    
end
mask_in=mask_in>0;
mask_out=mask_out>0;
end