function apply_classification(layer,varargin)

p = inputParser;

addRequired(p,'layer',@(x) isa(x,'layer_cl'));
addParameter(p,'primary_freq',layer.Frequencies(1),@isnumeric);
addParameter(p,'idx_schools',[],@isnumeric);
addParameter(p,'denoised',0,@isnumeric);
addParameter(p,'classification_file',fullfile(whereisEcho,'config','classification','classification.xml'),@ischar);

parse(p,layer,varargin{:});

primary_freq=p.Results.primary_freq;
idx_schools=p.Results.idx_schools;
classification_file=p.Results.classification_file;

disp('Applying classification');


[trans_obj_primary,idx_primary_freq]=layer.get_trans(primary_freq);
if isempty(trans_obj_primary)
    warning('Cannot find %dkHz! Cannot apply classification here....',primary_freq/1e3);
    return;
end

if isempty(idx_schools)
    idx_schools=trans_obj_primary.find_regions_type('Data');
    if isempty(idx_schools)
        warning('No regions defined on %dkHz!',primary_freq/1e3);
    end
end


if exist(classification_file,'file')>0
    try
        class_tree_obj=decision_tree_cl(classification_file);
    catch
        warning('Cannot parse specified classification file: %s',classification_file);
    end
else
    warning('Cannot find specified classification file: %s',classification_file);
    return;
end

%freqs=class_tree_obj.get_frequencies();
vars=class_tree_obj.get_variables();


idx_var_freq=find(contains(vars,'sv_'));
idx_var_freq_sec=find(contains(vars,'delta_sv_'));
primary_freqs=nan(1,numel(idx_var_freq));
secondary_freqs=nan(1,numel(idx_var_freq));

for i=1:numel(idx_var_freq)
    if ismember(i,idx_var_freq_sec)
        freqs_tmp=textscan(vars{idx_var_freq(i)},'delta_sv_%d_%d');
    else
        freqs_tmp=textscan(vars{idx_var_freq(i)},'sv_%d');
    end
    primary_freqs(i)=freqs_tmp{1}*1e3;
    if ismember(i,idx_var_freq_sec)
        secondary_freqs(i)=freqs_tmp{2}*1e3;
    end
end

nb_schools=numel(idx_schools);
idx_primary_freqs=nan(1,numel(primary_freqs));
idx_secondary_freqs=nan(1,numel(primary_freqs));
school_struct=cell(nb_schools,1);

for i=1:numel(primary_freqs)
    [idx_primary_freqs(i),found]=find_freq_idx(layer,primary_freqs(i));
    
    if ~found
        warning('Cannot find %dkHz! Cannot apply classification here....',primary_freqs(i)/1e3);
        return;
    end
    if ~isnan(secondary_freqs(i))
        [idx_secondary_freqs(i),found]=find_freq_idx(layer,secondary_freqs(i));
        if ~found
            warning('Cannot find %dkHz! Cannot apply classification here....',secondary_freqs(i)/1e3);
            return;
        end
    end
end

idx_freq_tot=union(idx_primary_freqs,idx_secondary_freqs);
idx_freq_tot(isnan(idx_freq_tot))=[];
[~,~,~,regCellInt,~,~,~,idx_freq_out_tot]=layer.multi_freq_slice_transect2D(...
    'SliceInt',0,'RegInt',1,'idx_regs',idx_schools,'idx_main_freq',idx_primary_freq,'idx_sec_freq',idx_freq_tot,'keep_all',1,'keep_bottom',1,'denoised',p.Results.denoised);


for j=1:nb_schools
    
    for i=1:numel(primary_freqs)
        i_freq_p=idx_freq_out_tot==idx_primary_freqs(i);
        output_reg_p=regCellInt{i_freq_p}{j};
        school_struct{j}.(sprintf('sv_%d',primary_freqs(i)/1e3))=pow2db_perso(nanmean(output_reg_p.Sv_mean_lin(:)));
        
        if ~isnan(idx_secondary_freqs(i))
            i_freq_s=idx_freq_out_tot==idx_secondary_freqs(i);
            output_reg_s=regCellInt{i_freq_s}{j};
            ns=numel(output_reg_s.nb_samples(:));
            np=numel(output_reg_p.nb_samples(:));
            n=nanmin(ns,np); 
            delta_temp=nanmean(pow2db_perso(output_reg_p.Sv_mean_lin(1:n))-pow2db_perso(output_reg_s.Sv_mean_lin(1:n)));
            delta_temp(isnan(delta_temp))=0;
            school_struct{j}.(sprintf('delta_sv_%d_%d',primary_freqs(i)/1e3,secondary_freqs(i)/1e3))=delta_temp;
            school_struct{j}.(sprintf('sv_%d',secondary_freqs(i)/1e3))=pow2db_perso(nanmean(output_reg_p.Sv_mean_lin(:)));
        end
    end
    
    school_struct{j}.nb_cell=length(~isnan(output_reg_p.Sv_mean_lin(:)));
    school_struct{j}.aggregation_depth_mean=nanmean(output_reg_p.Depth_mean(:));
    school_struct{j}.aggregation_depth_min=nanmax(output_reg_p.Depth_mean(:));
    school_struct{j}.bottom_depth=nanmean(trans_obj_primary.get_bottom_range(output_reg_p.Ping_S(1):output_reg_p.Ping_E(end)));
    school_struct{j}.lat_mean=nanmean(output_reg_p.Lat_E(:));
end

for j=1:length(school_struct)
    tag=class_tree_obj.apply_classification_tree(school_struct{j});
    trans_obj_primary.Regions(idx_schools(j)).Tag=tag;
end

end

