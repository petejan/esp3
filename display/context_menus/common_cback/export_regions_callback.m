function export_regions_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[trans_obj,idx_freq]=layer.get_trans(curr_disp);
reg_curr=trans_obj.get_region_from_Unique_ID(curr_disp.Active_reg_ID);
[path_tmp,~,~]=fileparts(layer.Filename{1});
layers_Str=list_layers(layer,'nb_char',80);


[fileN, pathname] = uiputfile({'*.xlsx','*.csv'},...
    'Save regions to file',...
    fullfile(path_tmp,[layers_Str{1} '_regions.xlsx']));
if isequal(pathname,0)||fileN==0
    return;
end

file=fullfile(pathname,fileN);
layer.export_region_to_xls(reg_curr,'output_f',file,'idx_freq',idx_freq);


end