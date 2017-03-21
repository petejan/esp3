%%[output_reg,slope_est,shadow_height_est]=estimate_shadow_zone.m
%
% _This section contains a very short description of the function, for the
% user to know this is part of ESP3 and what it is. Example below to
% replace. Delete these lines._ 
%
% Template of ESP3 function header.
%
%% Help
%
% *USE*
%
% _This section contains a more detailed description of what the function
% does and how to use it, for the interested user to have an overall
% understanding of its function. Example below to replace. Delete these
% lines._  
%
% This is a text file containing the basic comment template to add at the
% start of any new ESP3 function to serve as function help. 
%
% *INPUT VARIABLES*
%
% _This section contains bullet points of input variables with types and
% description. Example below to replace. Delete these lines._  
%
% 'output_variable_1' (required). Valid Options:
%
% * char: description
% * cell: description
%
% 'output_variable_2' (optional). Valid Options:
%
% * 1xN numeric array: description
%
% 'output_variable_3' (parameter). Valid Options:
%
% * struct: description
%
% *OUTPUT VARIABLES*
%
% _This section contains bullet points of output variables. Example below
% to replace. Delete these lines._ 
%
% * 'output_variable_1': type and description
% * 'output_variable_2': type and description
%
% *RESEARCH NOTES*
%
% _This section describes what features are temporary, needed future
% developments and paper references. Example below to replace. Delete these lines._
%
% * research point 1
% * research point 2
%
% *NEW FEATURES*
%
% _This section contains dates and descriptions of major updates. Example
% below to replace. Delete these lines._
%
% * YYYY-MM-DD: second version. Describes the update.
% * YYYY-MM-DD: first version.
%
% *EXAMPLE*
%
% _This section contains examples of valid function calls. Note that
% example lines start with 3 white spaces so that the publish function
% shows them correctly as matlab code. Example below to replace. Delete
% these lines._ 
%
%   example_use_1; % comment on what this does.
%   example_use_2: % comment on what this line does.
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% _This last section contains at least author name and affiliation. Delete
% these lines._ 
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function

function [output_reg,slope_est,shadow_height_est]=estimate_shadow_zone(trans_obj,varargin)
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
parse(p,trans_obj,varargin{:});

reg_sh=trans_obj.create_WC_region(...
    'y_min',p.Results.Shadow_zone_height,...
    'y_max',0,...
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

output_reg=trans_obj.integrate_region(reg_sh,'horiExtend',[p.Results.StartTime p.Results.EndTime],...
        'denoised',p.Results.Denoised,'motion_correction',p.Results.Motion_correction,'intersect_only',1);

[shadow_height_est,slope_est] = trans_obj.get_shadow_zone_height_est();



