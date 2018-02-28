%% estimate_shadow_zone.m
%
% TODO
%
%% Help
%
% *USE*
%
% TODO
%
% *INPUT VARIABLES*
%
% * |trans_obj|: Object of class |transceiver_cl| (Required)
% * |Slice_w|: Slice width (Optional. Positive num. Default: |10|).
% * |Slice_units|: Units for slice width (Optional. Char with valid options: |'pings'|
% or |'meters'|. Default: |'meters'|).
% * |StartTime|: Start time (Optional. Positive num. Default: |0|). 
% * |EndTime|: End time (Optional. Positive num. Default: |Inf|).
% * |Motion_correction|: Motion correction (Optional. Num. Default: |0|). 
% * |Denoised|: TODO (Optional. Num. Default: |0|).
% * |Shadow_zone_height|: TODO (Optional. Num. Default: |10|).
% * |DispReg| TODO (Optional. Default: |0|).
% * |intersect_only| TODO (Optional. Default: |1|).
%
% *OUTPUT VARIABLES*
%
% * |output_reg|: TODO
% * |slope_est|: TODO
% * |shadow_height_est|: TODO
%
% *RESEARCH NOTES*
%
% TODO: complete header and in-code commenting
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments (Alex Schimel
% * 2017-03-21: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% TODO
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function [output_reg,slope_est,shadow_height_est] = estimate_shadow_zone(trans_obj,varargin)

%% Checking and parsing input variables
p = inputParser;
addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addParameter(p,'Slice_w',10,@(x) x>0);
addParameter(p,'Slice_units','meters',@(unit) ~isempty(strcmp(unit,{'pings','meters'})));
addParameter(p,'StartTime',0,@(x) x>0);
addParameter(p,'EndTime',Inf,@(x) x>0);
addParameter(p,'Motion_correction',0,@isnumeric);
addParameter(p,'Denoised',0,@isnumeric);
addParameter(p,'Shadow_zone_height',10,@isnumeric);
addParameter(p,'DispReg',0);
addParameter(p,'idx_regs',[]);
addParameter(p,'regs',region_cl.empty(),@(x) isa(x,'region_cl'));
addParameter(p,'intersect_only',1);
parse(p,trans_obj,varargin{:});

reg_sh = trans_obj.create_WC_region(...
    'y_max',p.Results.Shadow_zone_height,...
    'y_min',0,...
    'Ref','Bottom',...
    'Cell_w',p.Results.Slice_w,...
    'Cell_h',p.Results.Shadow_zone_height,...
    'Cell_w_unit',p.Results.Slice_units,...
    'Cell_h_unit','meters');
% 
% trans_obj.add_region(reg_sh);

% if p.Results.DispReg>=0
%     reg_sh.display_region(trans_obj);
% end

output_reg = trans_obj.integrate_region_v4(reg_sh,'horiExtend',[p.Results.StartTime p.Results.EndTime],...
        'denoised',p.Results.Denoised,...
        'motion_correction',p.Results.Motion_correction,...
        'intersect_only',p.Results.intersect_only,...
        'idx_reg',p.Results.idx_regs,...
        'regs',p.Results.regs,...
        'select_reg','selected','keep_all',1);

[shadow_height_est,slope_est] = trans_obj.get_shadow_zone_height_est();



