function export_gps_data_to_shapefile_callback(src,~,main_figure,IDs)

layers=getappdata(main_figure,'Layers');
if isempty(layers)
    return;
end

if ~iscell(IDs)
    IDs={IDs};
end

if isempty(IDs{1})
    layer=layers(1);
    IDs=layer.Unique_ID;
else
   [idx,~]=find_layer_idx(layers,IDs{1}); 
   layer=layers(idx);
end

[path_lay,~]=layer.get_path_files();

[filename, pathname] = uiputfile('*.shp',...
    'Export GPS data to shapefile',...
    fullfile(path_lay{1},'gps_data.shp'));

if isequal(filename,0) || isequal(pathname,0)
    return;
end

export_gps_data_to_shapefile(layers,fullfile(pathname,filename),IDs);