function open_FCV30_file(main_figure,file_lst)


layers=getappdata(main_figure,'Layers');
app_path=getappdata(main_figure,'App_path');

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');



list_files=importdata(file_lst);
filename_ini=cell(1,length(list_files));

for i=1:length(list_files)
    str_temp=strsplit(list_files{i},',');
    filename_ini{i}=str_temp{2};
end
filename_ini=unique(filename_ini);

[fidx,cancel]=listdlg('ListString',filename_ini,'InitialValue',1:length(filename_ini),'Name','Choose Files to open');

if cancel==0
    return;
end


new_layers=open_FCV30_file_stdalone(file_lst,...
    'PathToMemmap',app_path.data_temp,'load_bar_comp',load_bar_comp,'file_idx',fidx);


% if ~isempty(new_layers)
%     new_layers.load_echo_logbook();
%     for i=1:length(new_layers)
%         new_layers(i).load_bot_regs();
%     end 
% else
%     return;
% end

new_layers=[layers new_layers];
new_layers_sorted=new_layers.sort_per_survey_data();
id_lay=new_layers(end).ID_num;

load_bar_comp.status_bar.setText('Shuffling layers');

layers_out=[];

for icell=1:length(new_layers_sorted)
    layers_out=[layers_out shuffle_layers(new_layers_sorted{icell},'multi_layer',-1)];
end


hide_status_bar(main_figure);
layers=layers_out;

layers=reorder_layers_time(layers);

[idx,~]=find_layer_idx(layers,id_lay);
layer=layers(idx);

% profile off
% profile viewer;

setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Layers',layers);