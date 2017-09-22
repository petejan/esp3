
function delete_display_algos_config_callback(~,~,main_figure,name)
curr_disp=getappdata(main_figure,'Curr_disp');

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end
update_algos(main_figure);
trans_obj=layer.get_trans(curr_disp.Freq);

algos=trans_obj.Algo;
[idx_algo,found]=find_algo_idx(trans_obj,name);
if found==0
    return;
end


switch name
    case {'BottomDetection' 'BottomDetectionV2' 'SchoolDetection'}
        switch name
            case 'BottomDetection'
                tab_comp=getappdata(main_figure,'Bottom_tab');
            case 'BottomDetectionV2'
                tab_comp=getappdata(main_figure,'Bottom_tab_v2');
            case 'SchoolDetection'
                tab_comp=getappdata(main_figure,'School_detect_tab');
        end
        names=get(tab_comp.default_params,'String');
        name_set=names(get(tab_comp.default_params,'value'));
        if strcmpi(name_set,'--')
            return;
        end
        write_config_algo_to_xml(algos(idx_algo),{name_set},1);
        names(get(tab_comp.default_params,'value'))=[];
        set(tab_comp.default_params,'String',names,'value',1);
end

end