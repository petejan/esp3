function open_asl_files(hObject,Filename)

layers=getappdata(hObject,'Layers');
app_path=getappdata(hObject,'App_path');

files_out={};
dates=[];

if ~iscell(Filename)
    [path_tmp,~,~]=fileparts(Filename);

    file_list=ls(fullfile(path_tmp,'*A'));
    out=textscan(file_list','%02f%02f%02f%02f.%02fA');
    dates=datenum([out{1}+2000 out{2} out{3} out{4} zeros(size(out{1})) zeros(size(out{1}))]);
    for id=1:length(dates)
        files_out{id}=fullfile(path_tmp,file_list(id,:));
    end
   
else
    il=0;
    [path_tmp,~]=fileparts_cell(Filename);
    path_tmp=unique(path_tmp);
    for i=1:length(path_tmp)
         file_list=ls(fullfile(path_tmp{i},'*A')); 
         out=textscan(file_list','%02f%02f%02f%02f.%02fA');
         dates=[dates datenum([out{1}+2000 out{2} out{3} out{4} zeros(size(out{1})) zeros(size(out{1}))])];
         for id=1:length(dates)
            il=il+1;
             files_out{il}=fullfile(path_tmp{i},file_list(id,:));
         end
    end
end
idx_selected_cell=cellfun(@(x)  find(strcmp(x,files_out)),Filename,'UniformOutput',false);
idx_selected=[idx_selected_cell{:}];

dates_selected=floor(dates(idx_selected));

dates_to_load=unique(floor(dates));

[~,idx_to_load_selected]=intersect(dates_to_load,dates_selected);

dates_to_load_str=datestr(dates_to_load);

[idx_out,cancel]=listdlg('ListString',dates_to_load_str,'InitialValue',idx_to_load_selected,'Name','Choose dates to load');

if cancel==0
    return;
end

dates_selected=unique(floor(dates_to_load(idx_out)));
idx_to_open=[];

for il=1:length(dates_selected)
    idx_to_open=union(idx_to_open,find(floor(dates)==dates_selected(il)));
end

Filename_out=files_out(idx_to_open);
dates_out=dates(idx_to_open);

fprintf('Openning %.0f day(s), that is %d files\n',length(idx_out),length(idx_to_open));

new_layers=read_asl(Filename_out,...
    'PathToMemmap',app_path.data_temp);
        
if isempty(new_layers)
    return;
end
max_load_days=7;
i_cell=1;
new_layers_sorted{i_cell}=[];
date_ori=dates_out(1);
for i_file=1:length(dates_out)
    if i_file>1
       if dates_out(i_file)-dates_out(i_file-1)>=1
           i_cell=i_cell+1;
           new_layers_sorted{i_cell}= new_layers(i_file);
           date_ori=dates_out(i_file);
           continue;
       end
    end
    if dates(i_file)-date_ori<=max_load_days
        new_layers_sorted{i_cell}=[new_layers_sorted{i_cell} new_layers(i_file)];
    else
        i_cell=i_cell+1;
        new_layers_sorted{i_cell}= new_layers(i_file);
        date_ori=dates_out(i_file);
    end
    
end


disp('Shuffling layers');
layers_out=[];

for icell=1:length(new_layers_sorted)
    layers_out=[layers_out shuffle_layers(new_layers_sorted{icell},'multi_layer',-1)];
end

id_lay=layers_out(end).ID_num;

layers=[layers layers_out];
layers=reorder_layers_time(layers);

[idx,~]=find_layer_idx(layers,id_lay);
layer=layers(idx);

% profile off
% profile viewer;



setappdata(hObject,'Layer',layer);
setappdata(hObject,'Layers',layers);


end