function import_bot_from_evl_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
[path_f,~,~]=fileparts(layer.Filename{1});

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.evl')}, 'Pick a .evl','MultiSelect','off');
if isempty(Filename)
    return;
end

trans_obj.setBottom_from_evl(fullfile(PathToFile,Filename))

setappdata(main_figure,'Layer',layer);
display_bottom(main_figure);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
order_stacks_fig(main_figure);
end