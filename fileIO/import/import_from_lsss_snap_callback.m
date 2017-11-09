function import_from_lsss_snap_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
[path_f,file_f,~]=fileparts(layer.Filename{1});


default_filename_snap=fullfile(path_f,[file_f '.snap']);
%default_filename_work=fullfile(path_f,[file_f '.work']);

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.snap;*.work')}, 'Pick a *.snap or *.work',default_filename_snap,'MultiSelect','off');
if isempty(Filename)||isnumeric(Filename)
    return;
end

trans_obj.set_bot_reg_from_lsss_snap(fullfile(PathToFile,Filename),idx_freq);


setappdata(main_figure,'Layer',layer);
display_bottom(main_figure);

display_regions(main_figure,'both');
curr_disp=getappdata(main_figure,'Curr_disp');
[trans_obj,idx_freq]=layer.get_trans(curr_disp);
curr_disp.Active_reg_ID=trans_obj.get_reg_first_Unique_ID();

set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
order_stacks_fig(main_figure);


end