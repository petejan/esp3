function closefcn_clean(src,~)
% User-defined close request function
% to display a question dialog box
selection = questdlg('Close The Programm?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection,
    case 'Yes',
        appdata = get(src,'ApplicationData');
        fns = fieldnames(appdata);
        for ii = 1:numel(fns)
            rmappdata(src,fns{ii});
        end
        delete(src);
    case 'No'

end