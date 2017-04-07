%% import_regs_from_evr_callback.m
%
% TODO: write short description of function
%
%% Help
%
% *USE*
%
% TODO: write longer description of function
%
% *INPUT VARIABLES*
%
% * |main_figure|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-03-28: header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function import_regs_from_evr_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    

curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
[path_f,~,~]=fileparts(layer.Filename{1});

[Filename,PathToFile]= uigetfile({fullfile(path_f,'*.evr')}, 'Pick a .evr','MultiSelect','off');
if ~ischar(Filename)
    return;
end

regions=create_regions_from_evr(fullfile(PathToFile,Filename),layer.Transceivers(idx_freq).get_transceiver_range(),layer.Transceivers(idx_freq).Data.Time);

if ~isempty(regions)
    layer.Transceivers(idx_freq).add_region(regions);
    setappdata(main_figure,'Layer',layer);
    display_bottom(main_figure);
    
    update_regions_tab(main_figure,1);
    update_reglist_tab(main_figure,[],0);
    display_regions(main_figure,'both');
    
    set_alpha_map(main_figure);
    set_alpha_map(main_figure,'main_or_mini','mini');
    order_stacks_fig(main_figure);
end

end