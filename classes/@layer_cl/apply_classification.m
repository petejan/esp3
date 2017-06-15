function h_figs=apply_classification(layer,idx_freq,idx_schools)
 h_figs=[];
class_tree_obj=decision_tree_cl(fullfile(whereisEcho,'config','classification.xml'));
disp('Applying classification');
nb_freq=numel(class_tree_obj.Frequencies);

nb_schools=numel(idx_schools);
idx_freq_tot=nan(1,nb_freq);
idx_school_cell=cell(nb_schools,nb_freq);
schools_output=cell(nb_schools,nb_freq);
school_struct=cell(nb_schools,1);

for i=1:nb_freq
    [idx_freq_tot(i),found]=find_freq_idx(layer,class_tree_obj.Frequencies(i));
    if ~found
        warning('Cannot find %dkHz! Cannot apply classification here....',class_tree_obj.Frequencies(i)/1e3);
        return;
    end
end


school_regs=layer.Transceivers(idx_freq).Regions(idx_schools);
layer.copy_region_across(idx_freq,school_regs,idx_freq_tot);
j=0;
uniquev=generate_couples(nb_freq);
for idx_school=idx_schools
    j=j+1;
    school_reg=layer.Transceivers(idx_freq).Regions(idx_school);
        
    for i=1:nb_freq        
        [idx_school_cell{j,i},found]=layer.Transceivers(idx_freq_tot(i)).find_reg_idx(school_reg.Unique_ID);
        if ~found
            warning('Cannot find school on %dkHz! ',class_tree_obj.Frequencies(i)/1e3);
            return;
        end
        if numel(idx_school_cell{j,i})>1
            warning('Several regions with similar ID/Name combination on one frequency...');
            return;
        end
        schools_output{j,i}=layer.Transceivers(idx_freq_tot(i)).integrate_region_v2(layer.Transceivers(idx_freq_tot(i)).Regions(idx_school_cell{j,i}),'denoised',0);

        if idx_freq_tot(i)==idx_freq
            school_struct{j}.nb_cell=length(~isnan(schools_output{j,i}.Sv_mean_lin(:)));
            school_struct{j}.aggregation_depth_mean=nanmean(schools_output{j,i}.Range_mean(:));
            school_struct{j}.aggregation_depth_min=nanmax(schools_output{j,i}.Range_mean(:));
            school_struct{j}.bottom_depth=nanmean(layer.Transceivers(idx_freq).get_bottom_range(schools_output{j,i}.Ping_S(1):schools_output{j,i}.Ping_E(end)));
            school_struct{j}.lat_mean=nanmean(schools_output{j,i}.Lat_E(:));
        end
    end
    
    
    for iu=1:numel(uniquev(:,1))       
        output_reg_1=schools_output{j,uniquev(iu,1)};
        output_reg_2=schools_output{j,uniquev(iu,2)};
        delta_temp=pow2db_perso(output_reg_1.Sv_mean_lin(:))-pow2db_perso(output_reg_2.Sv_mean_lin(:));
        school_struct{j}.(sprintf('delta_sv_%d_%d_mean',class_tree_obj.Frequencies(uniquev(iu,1))/1e3,class_tree_obj.Frequencies(uniquev(iu,2))/1e3))=delta_temp;
        school_struct{j}.(sprintf('delta_sv_%d_%d_mean',class_tree_obj.Frequencies(uniquev(iu,2))/1e3,class_tree_obj.Frequencies(uniquev(iu,1))/1e3))=-delta_temp;
    end
    
end


for j=1:length(school_struct)
    
    tag=class_tree_obj.apply_classification_tree(school_struct{j});
    for i=1:nb_freq
        layer.Transceivers(idx_freq_tot(i)).Regions(idx_school_cell{j,i}).Tag=tag;
    end
    
end

end

