
function  open_EK60_file(hObject,Filename,vec_freq,ping_start,ping_end,multi_layer,join)
layers=getappdata(hObject,'Layers');

app_path=getappdata(hObject,'App_path');

sple_start=1;
sple_end=inf;

% if multi_layer==-1
%     prompt={'First Sample:',...
%         'Last Sample:'};
%     name='Nb_samples to load from each files';
%     numlines=1;
%     defaultanswer={'1','Inf'};
%     answer=inputdlg(prompt,name,numlines,defaultanswer);
%     
%     if isempty(answer)
%         return;
%     end
%     sple_start= str2double(answer{1});
%     sple_end= str2double(answer{2});
% end



        
% profile on
new_layers=open_EK60_file_stdalone(Filename,...
    'PathToMemmap',app_path.data_temp,'Frequencies',vec_freq,'PingRange',[ping_start ping_end],'SampleRange',[sple_start sple_end]);
        

if exist('opening_file','var')
    close(opening_file);
end

if isempty(new_layers)
    return;
end

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

% profile off
% profile viewer;



setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);

end