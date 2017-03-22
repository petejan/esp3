%% closefcn_clean.m
%
% User-defined close request function (figure property 'CloseRequestFcn')
% for ESP3.
%
%% Help
%
% *USE*
%
% Only called when the ESP3 main_figure is being closed, to ensure ESP3
% exits in a clean state
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
% NA
%
% *NEW FEATURES*
%
% * 2017-03-22: header and comments updated according to new format (Alex Schimel)
% * 2017-03-02: Comments and header (Alex Schimel)
% * YYYY-MM-DD: first version (Yoann Ladroit)
%
% *EXAMPLE*
%
% NA
%
% *AUTHOR, AFFILIATION & COPYRIGHT*
%
% Yoann Ladroit, NIWA. Type |help EchoAnalysis.m| for copyright information.

%% Function
function closefcn_clean(main_figure,~)

%%% Check if there are unsaved bottom and regions
check_saved_bot_reg(main_figure);

%%% Open Close dialog box
selection=close_dialog_fig(main_figure);

%%% Handle answer
switch selection
    case 'Yes'
        % Clean up the app before closing
       cleanup_echo(main_figure);
    case 'No'
        return;
end



end