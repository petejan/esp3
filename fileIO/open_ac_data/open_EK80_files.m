function open_EK80_files(main_figure,PathToFile,Filename,vec_freq_init,ping_start,ping_end,multi_layer,join)
layers=getappdata(main_figure,'Layers');
app_path=getappdata(main_figure,'App_path');

if multi_layer<0
    multi_layer=0;
end

layers_temp=open_EK80_file_stdalone(PathToFile,Filename,'Frequencies',vec_freq_init,'PingRange',[ping_start ping_end],'PathToMemmap',app_path.data);
disp('Shuffling layers');
[layers,layer]=shuffle_layers(layers,layers_temp,'multi_layer',multi_layer,'join',join);

setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Layers',layers);

clear data transceiver

end