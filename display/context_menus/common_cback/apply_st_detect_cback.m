
function apply_st_detect_cback(~,~,select_plot,main_figure)
%  apply_st_detect_cback(~,~,select_plot,main_figure)
%
% DESCRIPTION
%
% -Apply single target detection on selected area or region_cl...
%
% USE
%
% [A bit more detailed description of how to use the function. DELETE THIS LINE IF UNUSED]
%
% PROCESSING SUMMARY
%
% - [Bullet point list summary of the steps in the processing.]
% - [DELETE THESE LINES IF UNUSED]
%
% INPUT VARIABLES
%
% - [Bullet point list description of input variables.]
% - [Describe if required, optional or parameters..]
% - [.. what are the valid values and what they do.]
% - [DELETE THESE LINES IF UNUSED]
%
% OUTPUT VARIABLES
%
% - [Bullet point list description of output variables.]
% - [DELETE THESE LINES IF UNUSED]
%
% RESEARCH NOTES
%
% [Describes what features are temporary or needed future developments.]
% [Also use for paper references.]
% [DELETE THESE LINES IF UNUSED]
%
% NEW FEATURES
%
% YYYY-MM-DD: [second version. Describes the update. DELETE THIS LINE IF UNUSED]
% 2017-03-02: first version.
%
% EXAMPLE
%
% % example 1:
% [This section contains examples of valid function calls.]
%
% % example 2:
% [DELETE THESE LINES IF UNUSED]
%
%%%
% Yoann Ladroit NIWA
%%%

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


alg_name='SingleTarget';

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
layer.Transceivers(idx_freq).apply_algo(alg_name,'load_bar_comp',load_bar_comp,'idx_r',idx_r,'idx_pings',idx_pings);
curr_disp.Bot_changed_flag=1; 
hide_status_bar(main_figure);

curr_disp.setField('singletarget');
curr_disp.Freq=curr_disp.Freq;
setappdata(main_figure,'Curr_disp',curr_disp);

end