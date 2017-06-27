%% filter_nan.m
%
% Moving average filter
%
%% Help
%
% *USE*
%
% [filtered_vec] = filter_nan(win,vec) applies (possibly weighted) moving
% average filter |win| to signal |vec|
%
% *INPUT VARIABLES*
%
% * |win|: filter
% * |vec|: signal
%
% *OUTPUT VARIABLES*
%
% * |filtered_vec|: filtered signal
%
% *RESEARCH NOTES*
%
% NA
%
% *NEW FEATURES*
%
% * 2017-06-27: header and comments (Alex Schimel)
% * 2016-06-17: first version controlled (Yoann Ladroit)
%
% *EXAMPLE*
%
% load('relatedsig','s1');
% s1 = s1';
% win = ones(1,10);
% s1_filt = filter_nan(win,s1);
% figure; plot(s1); hold on; plot(s1_filt);
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [filtered_vec] = filter_nan(win,vec)

% weighted moving average filter

% vec: input signal
% win: filter window

% signal and filter window lengths
lar_filt = length(win);
lar_vec = length(vec);

% initialize output
filtered_vec = nan(1,lar_vec);

if lar_vec >= lar_filt
    % signal is longer than filter window. Signal can be filtered
    
    % pad the signal with flipped versions of signal
    vec_temp = [ fliplr(vec(1:floor((lar_filt+1)/2)-1)) vec fliplr(vec(end-floor((lar_filt+1)/2)+1:end)) ];
    
    % apply filter to signal
    for i = 1:lar_vec
        filtered_vec(i) = nanmean(vec_temp(i:i+lar_filt-1).*win);
    end
    
else
    % signal is shorter than filter window. Signal can't be filtered
    
    % output nans
    filtered_vec = nan(1,lar_vec);
    
end

end

