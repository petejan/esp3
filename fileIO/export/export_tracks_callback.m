function export_tracks_callback(~,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layer_obj=getappdata(main_figure,'Layer');

if isempty(layer_obj)
    disp('No Layer opened')
    return;
end

[idx_freq,found]=find_freq_idx(layer_obj,curr_disp.Freq);
if found==0
    return;
end

trans_obj=layer_obj.Transceivers(idx_freq);
ST=trans_obj.ST;
Tracks=trans_obj.Tracks;
if isempty(Tracks.target_id)
    disp('No Tacks to export.')
    return;
end

Freq=layer_obj.Frequencies(idx_freq);
Filename=layer_obj.Filename{1};

if iscell(Filename)
    Filename=Filename{1};
end

file_outputs_def=[layer_obj.PathToFile '\' Filename(1:end-5) '_' num2str(Freq) '_tracks.csv'];

[file_outputs,path_out] = uiputfile('*.csv','Select Filename for saving output',file_outputs_def);

if ~isequal(file_outputs,0)&&~isequal(path_out,0)   
    new_struct=tracks_to_struct(ST,Tracks);
    struct2csv(new_struct,fullfile(path_out,file_outputs)); 
end

end
