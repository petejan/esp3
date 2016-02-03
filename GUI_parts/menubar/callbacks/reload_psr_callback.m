function reload_psr_callback(~,~,main_figure)
layers=getappdata(main_figure,'Layers');

choice = questdlg('WARNING: This will replace all previously loaded Regions?', ...
                'Bottom/Region',...
                'Yes','No', ...
                'No');
            % Handle response
            switch choice
                case 'No'
                    return;      
            end

for i=1:length(layers)
    for uui=1:length(layers(i).Frequencies)
        layers(i).Transceivers(uui).rm_region_origin('saved');
    end   
    layers(i).load_regs();
end
setappdata(main_figure,'Layers',layers);
update_display(main_figure,0);
update_algos(main_figure);

end