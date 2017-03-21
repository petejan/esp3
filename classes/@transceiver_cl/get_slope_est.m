function [slope_est,bot_range] = get_slope_est( trans_obj,varargin )
% [slope_est,bot_range] = get_slope_est( trans_obj,'width',10 )
%
% DESCRIPTION
%
% Gives a slope estimation of the bottom measured on the associated
% transducer using the depth line as reference
%
% USE
%
% PROCESSING SUMMARY
%
% INPUT VARIABLES
%
% - trans_obj: transceiver_cl
% - varargin: 'FilterWidth': filter width (in meters) for smoothing the
% bottom and the vessel distance
%       
% OUTPUT VARIABLES
%
% slope_est : estimated slope
% bot_range : bottom range corrected from transducer depth
%
% RESEARCH NOTES
%
% NEW FEATURES
%
% 2017-03-15: first version.
% EXAMPLE
%
%
%%%
% Yoann Ladroit& NIWA
%%%


p = inputParser;

addRequired(p,'trans_obj',@(x) isa(x,'transceiver_cl'));
addParameter(p,'FiltWidth',100,@isnumeric);

parse(p,trans_obj,varargin{:});

results=p.Results;
bot_range=trans_obj.get_bottom_range();

if ~isempty(trans_obj.OffsetLine)
    bot_range=bot_range(:)'-trans_obj.OffsetLine.Range(:)';
end

dist_vessel=trans_obj.get_dist();

[counts,hist_diff]=hist(diff(dist_vessel));
[~,idx]=nanmax(counts);
s_width=results.FiltWidth/(hist_diff(idx));

bot_data_filt=smooth(bot_range(:),s_width);
dist_vessel_filt=smooth(dist_vessel(:),s_width);
dist_vessel_filt(diff(dist_vessel_filt)<hist_diff(idx)/4)=nan;
slope_est=nan(size(bot_range));
slope_est(1:end-1)=atand(diff(bot_data_filt(:)')./diff(dist_vessel_filt(:)'));
