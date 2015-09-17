function layer_out=concatenate_layers(layer_1,layer_2)
if iscell(layer_1.Filename)||iscell(layer_2.Filename)
    newname=[layer_1.Filename layer_2.Filename];
else
    newname={layer_1.Filename layer_2.Filename};
end
layer_out=layer_cl('ID_num',layer_1.ID_num,...
    'Filename',newname...
    ,'Filetype',layer_1.Filetype,...
    'PathToFile',layer_1.PathToFile,...
    'Transceivers',concatenate_Transceivers(layer_1.Transceivers,layer_2.Transceivers),...
    'AttitudeNav',concatenate_AttitudeNavPing(layer_1.AttitudeNav,layer_2.AttitudeNav),...
    'GPSData',concatenate_GPSData(layer_1.GPSData,layer_2.GPSData),...
    'Frequencies',layer_1.Frequencies);

end