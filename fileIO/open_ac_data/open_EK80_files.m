function open_EK80_files(main_figure,PathToFile,Filename,vec_freq_init,ping_start,ping_end,multi_layer,join)
layers=getappdata(main_figure,'Layers');
app_path=getappdata(main_figure,'App_path');

if multi_layer<0
    multi_layer=0;
end

layers_temp=open_EK80_file_stdalone(PathToFile,Filename,'Frequencies',vec_freq_init,'PingRange',[ping_start ping_end],'PathToMemmap',app_path.data);

for i=1:length(layers_temp)
    layers_temp(i).load_bot_regs();
end


disp('Shuffling layers');
if join==1
    layers_temp=[layers layers_temp];
end

disp('Shuffling layers');
layers_out=shuffle_layers(layers_temp,'multi_layer',multi_layer);
clear layers_temp;

for i=1:length(layers_out)
    layers_out(i).load_echo_logbook();
end

if join==1
    layers=layers_out;
else
    layers=[layers layers_out];
end

layer=layers(end);



setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Layers',layers);

clear data transceiver

end