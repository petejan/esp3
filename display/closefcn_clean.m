function closefcn_clean(src,~)
% User-defined close request function
% to display a question dialog box

selection = questdlg('Close The Program?',...
    'Close Request Function',...
    'Yes','No','Yes');
switch selection,
    case 'Yes'
        hfigs=getappdata(src,'ExternalFigures');
        delete(hfigs);
        
        layers=getappdata(src,'Layers');
        
        i=length(layers);
        while i>=1
            try
                layers=layers.delete_layers(layers(i).ID_num);
            end
            
            i=i-1;
        end
        
        close_figures_callback([],[],src)
        
        appdata = get(src,'ApplicationData');
        fns = fieldnames(appdata);
        for ii = 1:numel(fns)
            rmappdata(src,fns{ii});
        end
        
        
        delete(src);
    case 'No'
        return;
end

end