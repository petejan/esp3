function plot_hist_st_callback(~,~,main_figure)

%  plot_hist_st_callback(~,~,main_figure)
%
% DESCRIPTION
%
% -Callback Plotting histogramm of detected Single target on currently
% displayed frequency
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

tag=sprintf('Single Targets from %.0f kHz',curr_disp.Freq/1e3);

[pdf_temp,x_temp]=pdf_perso(ST.TS_comp,'bin',25);
hfig=figure();
bar(x_temp,pdf_temp);
xlabel('TS(dB)');
ylabel('Pdf');
title(tag);
grid on;
new_echo_figure(main_figure,'fig_handle',hfig);


setappdata(main_figure,'Layer',layer);

end