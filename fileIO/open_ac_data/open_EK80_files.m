function open_EK80_files(main_figure,Filename,vec_freq_init,ping_start,ping_end,multi_layer,join)
layers=getappdata(main_figure,'Layers');
app_path=getappdata(main_figure,'App_path');

if multi_layer<0
    multi_layer=0;
end

new_layers=open_EK80_file_stdalone(Filename,'Frequencies',vec_freq_init,'PingRange',[ping_start ping_end],'PathToMemmap',app_path.data_temp);

for i=1:length(new_layers)
    new_layers(i).load_bot_regs();
end


new_layers.load_echo_logbook();

if join==1
    new_layers=[layers new_layers];
end


new_layers_sorted=new_layers.sort_per_survey_data();

disp('Shuffling layers');
layers_out=[];

for icell=1:length(new_layers_sorted)
    layers_out=[layers_out shuffle_layers(new_layers_sorted{icell},'multi_layer',multi_layer)];
end

id_lay=layers_out(end).ID_num;

if join==1
    layers=layers_out;
else
    layers=[layers layers_out];
end

layers=reorder_layers_time(layers);

[idx,~]=find_layer_idx(layers,id_lay);
layer=layers(idx);


setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Layers',layers);

clear data transceiver

end