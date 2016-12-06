function closefcn_clean(main_fig,~)
% User-defined close request function
% to display a question dialog box
selection=close_dialog_fig(main_fig);
% selection = questdlg('Close The Program?',...
%     '',...
%     'Yes','No','Yes');
switch selection,
    case 'Yes'
       cleanup_echo(main_fig);
       close all;
    case 'No'
        return;
end

end