
function  open_raw_file(hObject,Filename,vec_freq,ping_start,ping_end)
layers=getappdata(hObject,'Layers');

app_path=getappdata(hObject,'App_path');

sple_start=1;
sple_end=inf;

new_layers_EK60=[];
new_layers_EK80=[];


ftype=cell(1,length(Filename));

if ~isempty(layers)
    [old_files,~]=layers.list_files_layers();
    idx_already_open=cellfun(@(x) nansum(strcmpi(x,old_files))>0,Filename);
    fprintf('File %s already open in existing layer\n',Filename{idx_already_open});
    Filename(idx_already_open)=[];
end

for i=1:length(Filename)
   ftype{i}=get_ftype(Filename{i}); 
end

idx_EK60=find(strcmpi(ftype,'EK60'));
idx_EK80=find(strcmpi(ftype,'EK80'));


if ~isempty(idx_EK60)
    new_layers_EK60=open_EK60_file_stdalone(Filename(idx_EK60),...
        'PathToMemmap',app_path.data_temp,'Frequencies',vec_freq,'PingRange',[ping_start ping_end],'SampleRange',[sple_start sple_end]);
end

if ~isempty(idx_EK80)
    new_layers_EK80=open_EK80_file_stdalone(Filename(idx_EK80),'Frequencies',vec_freq_init,'PingRange',[ping_start ping_end],'PathToMemmap',app_path.data_temp);
end

new_layers=[new_layers_EK60 new_layers_EK80];

if exist('opening_file','var')
    close(opening_file);
end

if ~isempty(new_layers)
    for i=1:length(new_layers)
        new_layers(i).load_bot_regs();
    end
    
    new_layers.load_echo_logbook();
end

new_layers=[layers new_layers];

new_layers_sorted=new_layers.sort_per_survey_data();

disp('Shuffling layers');
layers_out=[];

for icell=1:length(new_layers_sorted)
    layers_out=[layers_out shuffle_layers(new_layers_sorted{icell},'multi_layer',-1)];
end

id_lay=layers_out(end).ID_num;

layers=layers_out;

layers=reorder_layers_time(layers);

[idx,~]=find_layer_idx(layers,id_lay);
layer=layers(idx);

% profile off
% profile viewer;



setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);

end