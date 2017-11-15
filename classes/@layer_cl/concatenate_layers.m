function layer_out=concatenate_layers(layer_1,layer_2)

newname=[layer_1.Filename layer_2.Filename];

layer_out=layer_cl('Filename',newname,...
    'Filetype',layer_1.Filetype,...
    'Lines',[layer_1.Lines layer_2.Lines],...
    'Transceivers',concatenate_Transceivers(layer_1.Transceivers,layer_2.Transceivers),...
    'AttitudeNav',concatenate_AttitudeNavPing(layer_1.AttitudeNav,layer_2.AttitudeNav),...
    'GPSData',concatenate_GPSData(layer_1.GPSData,layer_2.GPSData),...
    'Frequencies',layer_1.Frequencies,...
    'ChannelID',layer_1.ChannelID,...
    'EnvData',layer_1.EnvData,...
    'Curves',[layer_1.Curves layer_2.Curves]);

layer_out.set_survey_data([layer_1.SurveyData layer_2.SurveyData]);

clear layer_1 layer_2;

end