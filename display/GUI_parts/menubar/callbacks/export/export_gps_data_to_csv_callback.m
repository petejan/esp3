function export_gps_data_to_csv_callback(src,~,main_figure,def,IDs)

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
end

export_gps_data_to_csv(layers,def,IDs);
