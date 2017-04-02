%% apply_school_detect_cback.m
%
% Apply school detection on selected area or region_cl
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |select_plot|: TODO
% * |main_figure|: Handle to main ESP3 window
%
% *OUTPUT VARIABLES*
%
% NA
%
% *RESEARCH NOTES*
%
% TODO
%
% *NEW FEATURES*
%
% * 2017-03-07: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function apply_school_detect_cback(~,~,select_plot,main_figure)

update_algos(main_figure);
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

switch class(select_plot)
    case 'matlab.graphics.primitive.Patch'
        r=layer.Transceivers(idx_freq).get_transceiver_range();

        idx_pings=round(nanmin(select_plot.XData)):round(nanmax(select_plot.XData));
        
        [~,idx_r_min]=nanmin(abs(r-nanmin(select_plot.YData)));
        
        [~,idx_r_max]=nanmin(abs(r-nanmax(select_plot.YData)));
        idx_r=idx_r_min:idx_r_max;
    case 'region_cl'
        idx_r=select_plot.Idx_r;
        idx_pings=select_plot.Idx_pings;
    otherwise
        return;
end


alg_name='SchoolDetection';

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
layer.Transceivers(idx_freq).apply_algo(alg_name,'load_bar_comp',load_bar_comp,'idx_r',idx_r,'idx_pings',idx_pings);

hide_status_bar(main_figure);

curr_disp.Freq=curr_disp.Freq;
setappdata(main_figure,'Curr_disp',curr_disp);

end