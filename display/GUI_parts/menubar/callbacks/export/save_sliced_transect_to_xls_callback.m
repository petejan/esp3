function save_sliced_transect_to_xls_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
[Slice_w,Slice_h]=curr_disp.get_dx_dy();

Slice_w_units=curr_disp.Xaxes_current;
idx_reg=trans_obj.find_regions_type('Data');

sh_height=10;

[path_tmp,fileN,~]=fileparts(layer.Filename{1});

path_tmp = uigetdir(path_tmp,...
    'Save Sliced transect to folder');
if isequal(path_tmp,0)
    return;
end

[output_2D_surf,output_2D_bot,regs,regCellInt,output_2D_sh,shadow_height_est]=layer.export_slice_transect_to_xls(...
    'idx_main_freq',idx_freq,'idx_sec_freq',[],...
    'Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h,...
    'RegInt',1,'Shadow_zone',0,'Shadow_zone_height',sh_height,'idx_regs',idx_reg,...
    'output_f',fullfile(path_tmp,fileN));

  reg_temp=trans_obj.create_WC_region(...
        'Ref','Surface',...
        'Cell_w',p.Results.Slice_w,...
        'Cell_h',p.Results.Slice_h,...
        'Cell_w_unit',p.Results.Slice_w_units,...
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