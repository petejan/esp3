%% cancel_create_region.m
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
% * |input_variable_1|: TODO: write description and info on variable
%
% *OUTPUT VARIABLES*
%
% * |output_variable_1|: TODO: write description and info on variable
%
% *RESEARCH NOTES*
%
% TODO: write research notes
%
% *NEW FEATURES*
%
% * 2017-05-24: first version (Author). TODO: complete date and comment
%
% *EXAMPLE*
%
% TODO: write examples
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function cancel_create_region(src,callbackdata,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');

if ~strcmp(curr_disp.CursorMode,'Create Region')
    return;
end

switch callbackdata.Key
    
    case {'escape'}
        axes_panel_comp=getappdata(main_figure,'Axes_panel');
        
        ah=axes_panel_comp.main_axes;
        
        u=findobj(ah,'Tag','reg_temp');
        delete(u);
        
      
        replace_interaction(main_figure,'interaction','WindowButtonMotionFcn','id',2);
        replace_interaction(main_figure,'interaction','WindowButtonUpFcn','id',2);
        
    otherwise
        
        
end





