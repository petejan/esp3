function save_new_display_algos_config_callback(~,~,main_figure,name)

answer=inputdlg('Enter new setting name','New Setting Names',1);

if isempty(answer)
    return;
end

new_name=answer{1};

switch name
    case {'BottomDetection' 'BottomDetectionV2' 'SchoolDetection'}
        switch name
            case 'BottomDetection'
                tab_comp=getappdata(main_figure,'Bottom_tab');
            case 'BottomDetectionV2'
                tab_comp=getappdata(main_figure,'Bottom_tab_v2');
            case 'SchoolDetection'
                tab_comp=getappdata(main_figure,'School_detect_tab');
            otherwise
                return
        end
        names=get(tab_comp.default_params,'String');
        names=union(names,new_name);
        
        idx=find(strcmpi(names,new_name));
        set(tab_comp.default_params,'String',names,'value',idx);
        save_display_algos_config_callback([],[],main_figure,name)

end