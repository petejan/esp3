function open_EK80_files(main_figure,PathToFile,Filename,vec_freq_init,ping_start,ping_end,multi_layer,join,load_reg)
curr_disp=getappdata(main_figure,'Curr_disp');
layers=getappdata(main_figure,'Layers');
app_path=getappdata(main_figure,'App_path');

if multi_layer<0
    multi_layer=0;
end

layers_temp=open_EK80_file_stdalone(PathToFile,Filename,'Frequencies',vec_freq_init,'PingRange',[ping_start ping_end],'PathToMemmap',app_path.data);

[layers,layer]=shuffle_layers(layers,layers_temp,'multi_layer',multi_layer,'join',join,'load_reg',load_reg);

idx_freq=find_freq_idx(layer,curr_disp.Freq);
curr_disp.Freq=layer.Frequencies(idx_freq);
curr_disp.setField('sv');
setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Layers',layers);
setappdata(main_figure,'Curr_disp',curr_disp);

clear data transceiver

end