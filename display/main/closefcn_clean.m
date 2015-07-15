function closefcn_clean(src,~)
% User-defined close request function
% to display a question dialog box
selection = questdlg('Close The Programm?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection,
    case 'Yes'
        layers=getappdata(src,'Layers');
        for uu=1:length(layers)
            for kk=1:length(layers(uu).Transceivers)
                if exist(layers(uu).Transceivers(kk).MatfileName,'file')>0
                    delete(layers(uu).Transceivers(kk).MatfileName);
                end
            end
        end
           
        appdata = get(src,'ApplicationData');
        fns = fieldnames(appdata);
        for ii = 1:numel(fns)
            rmappdata(src,fns{ii});
        end
        delete(src);
    case 'No'

end