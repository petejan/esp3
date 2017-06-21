%% shift_bottom_callback.m
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
% * |select_plot|: TODO: write description and info on variable
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
% * 2017-03-28: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function shift_bottom_callback(~,~,select_plot,main_figure)
    
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

switch class(select_plot)
    case 'region_cl'

        idx_pings=select_plot.Idx_pings;
        
    otherwise
        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        
end



answer=inputdlg('Enter Shifting value','Shift Bottom',1,{'0'});

if isempty(answer)||isnan(str2double(answer{1}))
    return;
end

layer.Transceivers(idx_freq).shift_bottom(str2double(answer{1}),idx_pings);


curr_disp.Bot_changed_flag=1; 

setappdata(main_figure,'Curr_disp',curr_disp);
setappdata(main_figure,'Layer',layer);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
display_bottom(main_figure);
order_stacks_fig(main_figure);

end