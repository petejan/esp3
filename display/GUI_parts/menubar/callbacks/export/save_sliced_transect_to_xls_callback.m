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

layer.export_slice_transect_to_xls(...
    'idx_main_freq',idx_freq,'idx_sec_freq',[],...
    'Slice_w',Slice_w,'Slice_w_units',Slice_w_units,'Slice_h',Slice_h,...
    'RegInt',1,'Shadow_zone',0,'Shadow_zone_height',sh_height,'idx_regs',idx_reg,...
    'output_f',fullfile(path_tmp,fileN),'disp_results','main_figure',main_figure);


end