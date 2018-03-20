function logbook_keypress_fcn(src,callbackdata,main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
path_db=getappdata(src,'path_data');

switch callbackdata.Key
    case 'f5'
        file_add=layer_cl().update_echo_logbook_dbfile('DbFile',fullfile(path_db,'echo_logbook.db'));
        reload_logbook_fig(ancestor(src,'uitab'),file_add);     
end


end