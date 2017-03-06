function closefcn_clean(main_figure,~)
% closefcn_clean(main_figure,~)
%
% DESCRIPTION
%
% User-defined close request function (figure property 'CloseRequestFcn')
% for ESP3.
%
% USE
%
% Only called when the ESP3 main_figure is being closed, to ensure ESP3
% exits in a clean state
%
% PROCESSING SUMMARY
%
% - Check if there are unsaved bottom and regions
% - Open Close dialog box
% - Clean up the app before closing
%
% INPUT VARIABLES
%
% - main_figure (required): ESP3 main figure
%
% RESEARCH NOTES
%
% NA
%
% NEW FEATURES
%
% 2017-03-02: Comments and header Alex
%
%%%
% Yoann Ladroit, NIWA
%%%

% Check if there are unsaved bottom and regions
check_saved_bot_reg(main_figure);

% Open Close dialog box
selection=close_dialog_fig(main_figure);

% Handle answer
switch selection
    case 'Yes'
        % Clean up the app before closing
       cleanup_echo(main_figure);
    case 'No'
        return;
end



end