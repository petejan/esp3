%% update_denoise_tab.m
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
function update_denoise_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
denoise_tab_comp=getappdata(main_figure,'Denoise_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
% f_s_sig=round(1/(layer.Transceivers(idx_freq).Params.SampleInterval(1)));
% c=(layer.EnvData.SoundSpeed);


[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'Denoise');
if found==0
     return
end

algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
varin=algo_obj.Varargin;

range=layer.Transceivers(idx_freq).get_transceiver_range();
pings=layer.Transceivers(idx_freq).get_transceiver_pings();

set(denoise_tab_comp.HorzFilt,'string',num2str(nanmin(varin.HorzFilt,length(pings)),'%.0f'),'callback',{@ check_fmt_box,1,length(pings),varin.HorzFilt,'%.0f'});

set(denoise_tab_comp.VertFilt,'string',num2str(nanmin(varin.VertFilt,range(end)),'%.2f'),'callback',{@ check_fmt_box,0,range(end),varin.VertFilt,'%.2f'});

set(denoise_tab_comp.NoiseThr,'string',num2str(varin.NoiseThr,'%.0f'));

set(denoise_tab_comp.SNRThr,'string',num2str(varin.SNRThr,'%.0f'));

%set(findall(denoise_tab_comp.denoise_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'Denoise_tab',denoise_tab_comp);
end

