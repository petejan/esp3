function import_bot_regs_from_xml_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

choice = questdlg('WARNING: This will replace all previously defined Regions?', ...
    'Bottom/Region',...
    'Yes','No', ...
    'No');
% Handle response
switch choice
    case 'No'
        return;
end

layer.load_bot_regs();
update_display(main_figure,0);



end