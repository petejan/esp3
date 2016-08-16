
function  open_raw_file(hObject,Filename,vec_freq,ping_start,ping_end)
layers=getappdata(hObject,'Layers');

app_path=getappdata(hObject,'App_path');

sple_start=1;
sple_end=inf;



if ~isempty(layers)
    [old_files,~]=layers.list_files_layers();
    idx_already_open=cellfun(@(x) nansum(strcmpi(x,old_files))>0,Filename);
    fprintf('File %s already open in existing layer\n',Filename{idx_already_open});
    Filename(idx_already_open)=[];
end


new_layers=open_raw_file_standalone_v2(Filename,...
    'PathToMemmap',app_path.data_temp,'Frequencies',vec_freq,'PingRange',[ping_start ping_end],'SampleRange',[sple_start sple_end],'LoadEKbot',1);


if ~isempty(new_layers)
    for i=1:length(new_layers)
        new_layers(i).load_bot_regs();
    end
    
    new_layers.load_echo_logbook();
end

new_layers=[layers new_layers];
new_layers_sorted=new_layers.sort_per_survey_data();
id_lay=new_layers(end).ID_num;
disp('Shuffling layers');
layers_out=[];

for icell=1:length(new_layers_sorted)
    layers_out=[layers_out shuffle_layers(new_layers_sorted{icell},'multi_layer',0)];
end

layers=layers_out;

layers=reorder_layers_time(layers);

[idx,~]=find_layer_idx(layers,id_lay);
layer=layers(idx);

% profile off
% profile viewer;

setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);

end