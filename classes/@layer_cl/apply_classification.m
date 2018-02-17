function apply_classification(layer,varargin)

p = inputParser;

addRequired(p,'layer',@(x) isa(x,'layer_cl'));
addParameter(p,'primary_freq',layer.Frequencies(1),@isnumeric);
addParameter(p,'idx_schools',[],@isnumeric);
addParameter(p,'classification_file',fullfile(whereisEcho,'config','classification.xml'),@ischar);

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

idx_var_freq=find(~(cellfun(@isempty,strfind(vars,'delta_sv'))));
primary_freqs=nan(1,numel(idx_var_freq));
secondary_freqs=nan(1,numel(idx_var_freq));

for i=1:numel(idx_var_freq)
    freqs_tmp=textscan(vars{idx_var_freq(i)},'delta_sv_%d_%d');
    primary_freqs(i)=freqs_tmp{1}*1e3;
    secondary_freqs(i)=freqs_tmp{2}*1e3;
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
    
    [idx_secondary_freqs(i),found]=find_freq_idx(layer,secondary_freqs(i));
    if ~found
        warning('Cannot find %dkHz! Cannot apply classification here....',secondary_freqs(i)/1e3);
        return;
    end
end


j=0;

for idx_school=idx_schools
    j=j+1;
    
    school_reg=trans_obj_primary.Regions(idx_school);
    
    if ~any(idx_primary_freqs==idx_primary_freq)&&~any(idx_secondary_freqs==idx_primary_freq)
        schools_output_temp=trans_obj_primary.integrate_region_v3(school_reg,'denoised',0,'keep_all',1);
    end
    
    for i=1:numel(primary_freqs)
        [regs,idx_freq_out,~,~]=layer.generate_regions_for_other_freqs(idx_primary_freq,school_reg,[idx_primary_freqs(i) idx_secondary_freqs(i)]);
        
        if idx_primary_freqs(i)==idx_primary_freq
            reg_prim=school_reg;
        else
            reg_prim=regs(idx_freq_out==idx_primary_freqs(i));
        end
        
        if idx_secondary_freqs(i)==idx_primary_freq
            reg_sec=school_reg;
        else
            reg_sec=regs(idx_freq_out==idx_secondary_freqs(i));
        end
               
        trans_obj_prim=layer.Transceivers(idx_primary_freqs(i));
        trans_obj_sec=layer.Transceivers(idx_secondary_freqs(i));
        
        schools_output_primary_temp=trans_obj_prim.integrate_region_v3(reg_prim,'denoised',0,'keep_all',1);
        schools_output_secondary_temp=trans_obj_sec.integrate_region_v3(reg_sec,'denoised',0,'keep_all',1);
        
        if idx_primary_freqs(i)==idx_primary_freq
            schools_output_temp=schools_output_primary_temp;
        end
        
        if idx_secondary_freqs(i)==idx_primary_freq
            schools_output_temp=schools_output_secondary_temp;
        end
               
        output_reg_1=schools_output_primary_temp;
        output_reg_2=schools_output_secondary_temp;
        
        delta_temp=nanmean(pow2db_perso(output_reg_1.Sv_mean_lin(:))-pow2db_perso(output_reg_2.Sv_mean_lin(:)));
        delta_temp(isnan(delta_temp))=0;
        school_struct{j}.(sprintf('delta_sv_%d_%d_mean',primary_freqs(i)/1e3,secondary_freqs(i)/1e3))=delta_temp;
        
    end
    
    school_struct{j}.nb_cell=length(~isnan(schools_output_temp.Sv_mean_lin(:)));
    school_struct{j}.sv_mean=pow2db_perso(nanmean(schools_output_temp.Sv_mean_lin(:)));
    school_struct{j}.aggregation_depth_mean=nanmean(schools_output_temp.Depth_mean(:));
    school_struct{j}.aggregation_depth_min=nanmax(schools_output_temp.Depth_mean(:));
    school_struct{j}.bottom_depth=nanmean(trans_obj_primary.get_bottom_range(schools_output_temp.Ping_S(1):schools_output_temp.Ping_E(end)));
    school_struct{j}.lat_mean=nanmean(schools_output_temp.Lat_E(:));   
end

for j=1:length(school_struct)    
   tag=class_tree_obj.apply_classification_tree(school_struct{j}); 
   trans_obj_primary.Regions(idx_schools(j)).Tag=tag;  
end

end

