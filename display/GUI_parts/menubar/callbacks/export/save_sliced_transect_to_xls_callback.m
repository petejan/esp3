function save_sliced_transect_to_xls_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');

trans_obj=layer.get_trans(curr_disp.Freq);

Slice_w=curr_disp.Grid_x;
Slice_w_units=curr_disp.Xaxes;
Slice_h=curr_disp.Grid_y;

idx_reg=trans_obj.find_regions_type('Data');

[output_surf,output_bot,regs,regCellInt,output_shadow_reg,shadow_height_est]=trans_obj.slice_transect2D_new_int(...
    'Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h,...
    'RegInt',1,'Shadow_zone',1,'Shadow_zone_height',10,'Idx_reg',idx_reg);

reg_temp=trans_obj.create_WC_region(...
    'Ref','Surface',...
    'Cell_w',Slice_w,...
    'Cell_h',Slice_h,...
    'Cell_w_unit',Slice_w_units,...
    'Cell_h_unit','meters');

[path_tmp,~,~]=fileparts(layer.Filename{1});
layers_Str=list_layers(layer,'nb_char',80);


if ~isempty(output_surf)
    reg_temp.display_region(output_surf,'main_figure',main_figure,'Name','Sliced Transect 2D (Surface Ref)');
        
    [fileN, path_tmp] = uiputfile('*.xlsx',...
        'Save Sliced transect (integration results)',...
        fullfile(path_tmp,[layers_Str{1} '_sliced_surf.xlsx']));
    
    if isequal(path_tmp,0)
        return;
    end
    
    if exist(fullfile(path_tmp,fileN),'file')>1
        delete(fullfile(path_tmp,fileN));
    end
    reg_output_sheet=reg_output_to_sheet(output_surf);
    xlswrite(fullfile(path_tmp,fileN),reg_output_sheet,1);
    
end

reg_temp.Reference='Bottom';

if ~isempty(output_bot)
    reg_temp.display_region(output_bot,'main_figure',main_figure,'Name','Sliced Transect 2D (Bottom Ref)');
    
    [fileN, path_tmp] = uiputfile('*.xlsx',...
        'Save Sliced transect (integration results)',...
        fullfile(path_tmp,[layers_Str{1} '_sliced_bot.xlsx']));
    
    if isequal(path_tmp,0)
        return;
    end
    
    if exist(fullfile(path_tmp,fileN),'file')>1
        delete(fullfile(path_tmp,fileN));
    end
    reg_output_sheet=reg_output_to_sheet(output_bot);
    xlswrite(fullfile(path_tmp,fileN),reg_output_sheet,1);
        
end


end