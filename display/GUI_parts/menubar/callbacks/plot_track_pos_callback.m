%% plot_track_pos_callback.m
%
% Callback plotting histogram of detected single target on currently
% displayed frequency.
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
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
% * 2017-07-03: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function plot_track_pos_callback(~,~,main_figure)

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);
if found==0
    return;
end

Transceiver=layer.Transceivers(idx_freq);

ST = Transceiver.ST;

if isempty(ST)
    return;
end

tag=sprintf('Single Targets position from %.0f kHz',curr_disp.Freq/1e3);

[pdf_temp,x_temp]=pdf_perso(ST.TS_comp,'bin',25);

hfig=new_echo_figure(main_figure,'tag','st_histo');
ax=axes(hfig);




setappdata(main_figure,'Layer',layer);

end