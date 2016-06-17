function import_bot_from_evl_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
[path_f,~,~]=fileparts(layer.Filename{1});

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.evl')}, 'Pick a .evl','MultiSelect','off');
if isempty(Filename)
    return;
end

layer.Transceivers(idx_freq).setBottom_from_evl(fullfile(PathToFile,Filename))

setappdata(main_figure,'Layer',layer);
load_axis_panel(main_figure,0);

end