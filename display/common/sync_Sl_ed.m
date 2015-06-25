function sync_Sl_ed(src,~,hObject,precision)

switch src.Style
    case 'edit'
        hObject_E=src;
        hObject_S=hObject;
        L = (get(hObject_S,{'min','max','value'}));
        E = str2double(get(hObject_E,'string'));
        if ~isnan(E)&&isnumeric(E)
            if E >= L{1} && E <= L{2}
                set(hObject_S,'value',E)
            elseif E < L{1}
                set(hObject_E,'string',num2str(L{1},precision))
            elseif E > L{3}
                set(hObject_E,'string',num2str(L{3},precision))
            end
        else
            set(hObject_E,'string',num2str((get(hObject_S,'value')),precision))
        end
    case 'slider'
        hObject_E=hObject;
        hObject_S=src;
        set(hObject_E,'string',num2str((get(hObject_S,'value')),precision))
end

end