
function  open_raw_file(main_figure,Filename,vec_freq,ping_start,ping_end)
layers=getappdata(main_figure,'Layers');
app_path=getappdata(main_figure,'App_path');

sple_start=1;
sple_end=inf;

if ~isempty(layers)
    [old_files,~]=layers.list_files_layers();
    idx_already_open=cellfun(@(x) any(strcmpi(x,old_files)),Filename);
    if any(idx_already_open)
        fprintf('File %s already open in existing layer\n',Filename{idx_already_open});
        Filename(idx_already_open)=[];
    end
end

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');

new_layers=open_raw_file_standalone_v2(Filename,...
    'PathToMemmap',app_path.data_temp,'Frequencies',vec_freq,'PingRange',[ping_start ping_end],'SampleRange',[sple_start sple_end],'LoadEKbot',1,'load_bar_comp',load_bar_comp);


if ~isempty(new_layers)
    load_bar_comp.status_bar.setText('Updating Database with GPS Data');
    new_layers.add_gps_data_to_db();
    
    load_bar_comp.status_bar.setText('Loading Survey Metadata');
    new_layers.load_echo_logbook_db();
    
    load_bar_comp.status_bar.setText('Loading Bottom and regions');
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(new_layers),'Value',0);
    for i=1:numel(new_layers)
        set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(new_layers),'Value',i);
        try
            new_layers(i).load_bot_regs();
        catch err
            disp(err.message);
            fprintf('Could not load bottom and region for layer %s',list_layers(new_layers(i),'nb_char',80));
        end
    end
    
    load_bar_comp.status_bar.setText('Loading Lines');
    set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(new_layers),'Value',0);
    
    for i=1:length(new_layers)
        set(load_bar_comp.progress_bar, 'Minimum',0, 'Maximum',numel(new_layers),'Value',i);
        try
            new_layers(i).add_lines_from_line_xml();
        catch err
            disp(err.message);
            laystr=list_layers(new_layers(i),'nb_char',80);
            fprintf('Could not load lines for layer %s',laystr{1});
        end
    end
else
    return;
end


new_layers=[layers new_layers];
new_layers_sorted=new_layers.sort_per_survey_data();
id_lay=new_layers(end).ID_num;

load_bar_comp.status_bar.setText('Shuffling layers');

layers_out=[];

for icell=1:length(new_layers_sorted)
    layers_out=[layers_out shuffle_layers(new_layers_sorted{icell},'multi_layer',-1)];
end


hide_status_bar(main_figure);

layers=reorder_layers_time(layers_out);

[idx,~]=find_layer_idx(layers,id_lay);
layer=layers(idx);

% profile off
% profile viewer;

setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Layers',layers);

end