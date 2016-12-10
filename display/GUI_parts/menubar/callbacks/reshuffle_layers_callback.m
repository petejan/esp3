
function reshuffle_layers_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

layers_sorted=layers.sort_per_survey_data();

disp('Shuffling layers');
layers_out=[];

for icell=1:length(layers_sorted)
    layers_out=[layers_out shuffle_layers(layers_sorted{icell},'multi_layer',0)];
end

id_lay=layers_out(end).ID_num;

layers_out=reorder_layers_time(layers_out);

[idx,~]=find_layer_idx(layers_out,id_lay);
layer_out=layers_out(idx);

setappdata(main_figure,'Layers',layers_out);
setappdata(main_figure,'Layer',layer_out);

loadEcho(main_figure);
end