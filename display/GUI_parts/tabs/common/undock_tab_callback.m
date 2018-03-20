function undock_tab_callback(~,~,main_figure,tab,dest)

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
switch tab
    case 'st_tracks'
        st_tracks_tab_comp=getappdata(main_figure,'ST_Tracks');
        tab_h=st_tracks_tab_comp.st_tracks_tab;
        tt='St&Tracks';
    case 'map'
        map_tab_comp=getappdata(main_figure,'Map_tab');
        cont_disp=map_tab_comp.cont_disp;
        cont_val=map_tab_comp.cont_val;
        idx_lays=map_tab_comp.idx_lays;
        coast_disp=map_tab_comp.coast_disp;
        all_lays=map_tab_comp.all_lays;
        tab_h=map_tab_comp.map_tab;
        tt='Map';
    case 'reglist'
        tab_comp=getappdata(main_figure,'Reglist_tab');
        tab_h=tab_comp.reglist_tab;
        tt='Region List';
    case 'laylist'
        tab_comp=getappdata(main_figure,'Layer_tree_tab');
        tab_h=tab_comp.layer_tree_tab;
        tt='Layers';       
    case 'sv_f'
        tab_comp=getappdata(main_figure,tab);
        tab_h=tab_comp.multi_freq_disp_tab;
        tt='Sv(f)';
    case 'ts_f'
        tab_comp=getappdata(main_figure,tab);
        tab_h=tab_comp.multi_freq_disp_tab;
        tt='TS(f)';
    case 'echoint_tab'
        tab_comp=getappdata(main_figure,'EchoInt_tab');
        tab_h=tab_comp.echo_int_tab;        
        tt='Echo-Integration';
    otherwise
        tab_h=[];
end

if~isvalid(tab_h)
    return;
end
pos_tab=getpixelposition(tab_h);
delete(tab_h);

switch dest
    case 'opt_tab'
        dest_fig=getappdata(main_figure,'option_tab_panel');
    case 'echo_tab'
        dest_fig=getappdata(main_figure,'echo_tab_panel');
    case 'new_fig'    
        dest_fig=new_echo_figure(main_figure,...
            'Units','pixels',...
            'Position',pos_tab,...
            'Name',tt,...
            'Resize','on',...
            'CloseRequestFcn',@close_tab,...
            'Tag',tab);
end


switch tab
    case 'st_tracks'
        load_st_tracks_tab(main_figure,dest_fig);
    case 'map'
        load_map_tab(main_figure,dest_fig,'cont_disp',cont_disp,'cont_val',cont_val,'coast_disp',coast_disp,'idx_lays',idx_lays,'all_lays',all_lays);
    case 'reglist'
        load_reglist_tab(main_figure,dest_fig);
    case 'laylist'
        load_tree_layer_tab(main_figure,dest_fig);
    case 'echoint_tab'
        load_echo_int_tab(main_figure,dest_fig);
    case {'sv_f' 'ts_f'}
        load_multi_freq_disp_tab(main_figure,dest_fig,tab);
end


end

function close_tab(src,~,main_figure)
tag=src.Tag;


dest_fig=getappdata(main_figure,'option_tab_panel');
switch tag
    case 'st_tracks'
        delete(src);
        load_st_tracks_tab(main_figure,dest_fig);
    case 'map'
        map_tab_comp=getappdata(main_figure,'Map_tab');
        cont_disp=map_tab_comp.cont_disp;
        cont_val=map_tab_comp.cont_val;
        idx_lays=map_tab_comp.idx_lays;
        coast_disp=map_tab_comp.coast_disp;
        all_lays=map_tab_comp.all_lays;
        delete(src);
        load_map_tab(main_figure,dest_fig,'cont_disp',cont_disp,'cont_val',cont_val,'coast_disp',coast_disp,'idx_lays',idx_lays,'all_lays',all_lays);
    case 'reglist'
        delete(src);
        load_reglist_tab(main_figure,dest_fig);
    case 'laylist'
        delete(src);
        load_tree_layer_tab(main_figure,dest_fig);
    case 'echoint_tab'
         echo_int_tab_comp=getappdata(main_figure,'EchoInt_tab');
         sliced_t=echo_int_tab_comp.sliced_t;
        dest_fig=getappdata(main_figure,'echo_tab_panel');
        delete(src);
        load_echo_int_tab(main_figure,dest_fig,sliced_t);
    case {'sv_f' 'ts_f'}
        delete(src);
        load_multi_freq_disp_tab(main_figure,dest_fig,tag);
end
end