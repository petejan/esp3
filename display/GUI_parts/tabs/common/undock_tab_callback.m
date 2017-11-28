function undock_tab_callback(~,~,main_figure,tab,dest)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
switch tab
    case 'map'
        map_tab_comp=getappdata(main_figure,'Map_tab');
        tab_h=map_tab_comp.map_tab;
        tt='Map&Co';
    case 'reglist'
        tab_comp=getappdata(main_figure,'Reglist_tab');
        tab_h=tab_comp.reglist_tab;
        tt='Region List';
    case 'laylist'
        tab_comp=getappdata(main_figure,'Layer_tab');
        tab_h=tab_comp.layer_tab;
        tt='Layers';       
    case 'sv_f'
        tab_comp=getappdata(main_figure,tab);
        tab_h=tab_comp.multi_freq_disp_tab;
        tt='Sv(f)';
    case 'ts_f'
        tab_comp=getappdata(main_figure,tab);
        tab_h=tab_comp.multi_freq_disp_tab;
        tt='TS(f)';
    otherwise
        tab_h=[];
end

if~isvalid(tab_h)
    return;
end
delete(tab_h);

switch dest
    case 'opt_tab'
        dest_fig=getappdata(main_figure,'option_tab_panel');
    case 'echo_tab'
        dest_fig=getappdata(main_figure,'echo_tab_panel');
    case 'new_fig'
        
        pos_fig=[0.2 0.2 0.6 0.4];
        dest_fig=new_echo_figure(main_figure,...
            'Units','normalized',...
            'Position',pos_fig,...
            'Name',tt,...
            'Resize','on',...
            'CloseRequestFcn',@close_tab,...
            'Tag',tab);
end


switch tab
    case 'map'
        load_map_tab(main_figure,dest_fig);
    case 'reglist'
        load_reglist_tab(main_figure,dest_fig);
    case 'laylist'
        load_layer_tab(main_figure,dest_fig);
    case {'sv_f' 'ts_f'}
        load_multi_freq_disp_tab(main_figure,dest_fig,tab);
end


end

function close_tab(src,~,main_figure)
tag=src.Tag;

delete(src);
dest_fig=getappdata(main_figure,'option_tab_panel');
switch tag
    case 'map'
        load_map_tab(main_figure,dest_fig);
    case 'reglist'
        load_reglist_tab(main_figure,dest_fig);
    case 'laylist'
        load_layer_tab(main_figure,dest_fig);
    case {'sv_f' 'ts_f'}
        load_multi_freq_disp_tab(main_figure,dest_fig,tag);
end
end