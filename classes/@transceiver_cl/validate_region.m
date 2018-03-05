%% my_Matlab_function_name.m
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
function region = validate_region(trans_obj,region,varargin)

p = inputParser;

addRequired(p,'trans_obj',@(trans_obj) isa(trans_obj,'transceiver_cl'));
addRequired(p,'region',@(obj) isa(obj,'region_cl')||isempty(obj));


parse(p,trans_obj,region,varargin{:});

pings_t=trans_obj.get_transceiver_pings();
Idx_r=trans_obj.get_transceiver_samples();

switch region.Shape
    case 'Rectangular'
        region.Idx_pings=intersect((1:length(pings_t)),region.Idx_pings);
        region.Idx_r=intersect(Idx_r,region.Idx_r);
    case 'Polygon'
        region.Idx_pings=intersect((1:length(pings_t)),region.Idx_pings);
        region.Idx_r=intersect(Idx_r,region.Idx_r);    
        region.Idx_r=intersect(Idx_r,region.Idx_r);
        region.MaskReg=region.get_sub_mask(1:length(region.Idx_r),1:length(region.Idx_pings));
        if ~any(region.MaskReg)
            region.Shape='Rectangular';
            region.MaskReg=[];
        end

end



