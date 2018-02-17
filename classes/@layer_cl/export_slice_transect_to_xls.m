function export_slice_transect_to_xls(layer_obj,varargin)

[path_tmp,~,~]=fileparts(layer_obj.Filename{1});
layers_Str=list_layers(layer_obj,'nb_char',80);
output_f_def=fullfile(path_tmp,layers_Str{1});

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
addParameter(p,'output_f',output_f_def,@ischar);
addParameter(p,'disp_results',output_f_def,@ischar);
addParameter(p,'main_figure',[],@(x) isempty(x)||ishandle(x));

parse(p,layer_obj,varargin{:});

[output_2D_surf_tot,output_2D_bot_tot,regs_tot,regCellInt_tot,output_2D_sh_tot,~,idx_freq_out]=layer_obj.multi_freq_slice_transect2D(...
    'idx_main_freq',p.Results.idx_main_freq,...
    'idx_sec_freq',p.Results.idx_sec_freq,...
    'idx_regs',p.Results.idx_regs,...
    'regs',p.Results.regs,...
    'Slice_w',p.Results.Slice_w,...
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

idx_main_freq=p.Results.idx_main_freq;
reg_descr_table=[];

if p.Results.RegInt
    output_f=[p.Results.output_f '_regions_descr.csv'];
    if exist(output_f,'file')>1
        delete(output_f);
    end
    for ireg=1:length(regs_tot{idx_freq_out==idx_main_freq})
        reg_descriptors=layer_obj.Transceivers(p.Results.idx_main_freq).get_region_descriptors(regs_tot{idx_freq_out==idx_main_freq}{ireg});
        for ir=1:length(idx_freq_out)
            output_reg=regCellInt_tot{ir}{ireg};
            output_reg.Sv_mean_lin(output_reg.Sv_mean_lin==0)=nan;
            Sv_mean=pow2db_perso(nanmean(output_reg.Sv_mean_lin(:)));
            delta_sv=nanstd(pow2db_perso(output_reg.Sv_mean_lin(:)));
            reg_descriptors.(sprintf('Sv_%.0fkHz',layer_obj.Frequencies(idx_freq_out(ir))/1e3))=Sv_mean;
            reg_descriptors.(sprintf('Delta_Sv_%.0fkHz',layer_obj.Frequencies(idx_freq_out(ir))/1e3))=delta_sv;
        end
        reg_descr_table = [reg_descr_table;struct2table(reg_descriptors,'asarray',1)];
    end
    writetable(reg_descr_table,output_f);
end


output_2D_surf=output_2D_surf_tot{p.Results.idx_main_freq==idx_freq_out};
output_2D_sh=output_2D_sh_tot{p.Results.idx_main_freq==idx_freq_out};
output_2D_bot=output_2D_bot_tot{p.Results.idx_main_freq==idx_freq_out};
% shadow_height_est=shadow_height_est_tot{p.Results.idx_main_freq==idx_freq_out};


idx_freq_other=setdiff(idx_freq_out,p.Results.idx_main_freq);

data_size_surf=size(output_2D_surf.nb_samples);
if ~isempty(output_2D_bot)
    data_size_bot=size(output_2D_bot.nb_samples);
end
if ~isempty(output_2D_sh)
    data_size_sh=size(output_2D_sh.nb_samples);
end
%figure();imagesc(pow2db_perso(output_2D_surf.Sv_mean_lin))
for ir=1:length(idx_freq_other)
    
    output_2D_surf_sec=output_2D_surf_tot{idx_freq_other(ir)==idx_freq_out};
    output_2D_sh_sec=output_2D_sh_tot{idx_freq_other(ir)==idx_freq_out};
    output_2D_bot_sec=output_2D_bot_tot{idx_freq_other(ir)==idx_freq_out};
    %shadow_height_est_sec=shadow_height_est_tot{idx_freq_other(ir)==idx_freq_out};
    
    [mask_in,mask_out]=match_data(output_2D_surf_sec.Time_S,output_2D_surf_sec.Range_ref_min,output_2D_surf.Time_S,output_2D_surf.Range_ref_min);
    output_2D_surf.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))=zeros(data_size_surf);
    output_2D_surf.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))(mask_out)=output_2D_surf_sec.Sv_mean_lin(mask_in);
    output_2D_surf.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))=zeros(data_size_surf);
    output_2D_surf.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))(mask_out)=output_2D_surf_sec.Sv_dB_std(mask_in);
    
    %figure();imagesc(pow2db_perso(output_2D_surf_sec.Sv_mean_lin));
    
    if ~isempty(output_2D_bot)
        %figure();imagesc(pow2db_perso(output_2D_bot_sec.Sv_mean_lin));
        [mask_in,mask_out]=match_data(output_2D_bot_sec.Time_S,output_2D_bot_sec.Range_ref_min,output_2D_bot.Time_S,output_2D_bot.Range_ref_min);
        output_2D_bot.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))=zeros(data_size_bot);
        output_2D_bot.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))(mask_out)=output_2D_bot_sec.Sv_mean_lin(mask_in);
        output_2D_bot.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))=zeros(data_size_bot);
        output_2D_bot.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))(mask_out)=output_2D_bot_sec.Sv_dB_std(mask_in);
    end
    
     if ~isempty(output_2D_sh)
         [mask_in,mask_out]=match_data(output_2D_sh_sec.Time_S,output_2D_sh_sec.Range_ref_min,output_2D_sh.Time_S,output_2D_sh.Range_ref_min);
        output_2D_sh.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))=zeros(data_size_sh);
        output_2D_sh.(sprintf('Sv_mean_lin_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))(mask_out)=output_2D_sh_sec.Sv_mean_lin(mask_in);
        output_2D_sh.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))=zeros(data_size_sh);
        output_2D_sh.(sprintf('Sv_dB_sd_%.0fkHz',layer_obj.Frequencies(idx_freq_other(ir))))(mask_out)=output_2D_sh_sec.Sv_dB_std(mask_in);
     end
        
end

output_f=[p.Results.output_f '_surf_sliced_transect.csv'];
reg_output_table=reg_output_to_table(output_2D_surf);
writetable(reg_output_table,output_f);

if ~isempty(output_2D_bot)
    output_f=[p.Results.output_f '_bot_sliced_transect.csv'];
    reg_output_table=reg_output_to_table(output_2D_bot);
    writetable(reg_output_table,output_f);
end

if ~isempty(output_2D_sh)
    output_f=[p.Results.output_f '_sh_sliced_transect.csv'];
    reg_output_table=reg_output_to_table(output_2D_sh);
    writetable(reg_output_table,output_f);
end

if p.Results.disp_results
    

reg_temp=trans_obj.create_WC_region(...
    'Ref','Surface',...
    'Cell_w',Slice_w,...
    'Cell_h',Slice_h,...
    'Cell_w_unit',Slice_w_units,...
    'Cell_h_unit','meters');

if ~isempty(output_2D_surf)
    try
        reg_temp.display_region(output_2D_surf,'main_figure',p.Results.main_figure,'Name','Sliced Transect 2D (Surface Ref)');
    catch
        disp('Could not display sliced transect (Surface referenced)');
    end
    
end

reg_temp.Reference='Bottom';

if ~isempty(output_2D_bot)
    try
        reg_temp.display_region(output_2D_bot,'main_figure',p.Results.main_figure,'Name','Sliced Transect 2D (Bottom Ref)');
    catch
       disp('Could not display sliced transect (Bottom Referenced)');
    end
    
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
