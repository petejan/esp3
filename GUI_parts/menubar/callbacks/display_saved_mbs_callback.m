function display_saved_mbs_callback(~,~,hObject_main)

mbs_vec=getappdata(hObject_main,'MBS');
if isempty(mbs_vec)
    return;
else
    load_map_fig(hObject_main,mbs_vec);
end

end