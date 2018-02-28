function [output_2D_surf,output_2D_bot,regs,regCellInt,output_2D_sh,shadow_height_est]=export_slice_transect_to_xls(layer_obj,varargin)

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

parse(p,layer_obj,varargin{:});

[output_2D_surf_tot,output_2D_bot_tot,regs_tot,regCellInt_tot,reg_descr_table,output_2D_sh_tot,~,idx_freq_out]=layer_obj.multi_freq_slice_transect2D(...
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



idx_main=p.Results.idx_main_freq==idx_freq_out;
regCellInt=regCellInt_tot{idx_main};
regs=regs_tot{idx_main};

if p.Results.RegInt
    output_f=[p.Results.output_f '_regions_descr.csv'];
    if exist(output_f,'file')>1
        delete(output_f);
    end
    writetable(reg_descr_table,output_f);
end

output_f=[p.Results.output_f '_surf_sliced_transect.csv'];
reg_output_table=reg_output_to_table(output_2D_surf_tot{idx_main});
writetable(reg_output_table,output_f);

if ~isempty(output_2D_bot_tot{idx_main})
    output_f=[p.Results.output_f '_bot_sliced_transect.csv'];
    reg_output_table=reg_output_to_table(output_2D_bot_tot{idx_main});
    writetable(reg_output_table,output_f);
end

if ~isempty(output_2D_sh_tot{idx_main})
    output_f=[p.Results.output_f '_sh_sliced_transect.csv'];
    reg_output_table=reg_output_to_table(output_2D_sh_tot{idx_main});
    writetable(reg_output_table,output_f);
end


end

