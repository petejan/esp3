function set_alpha_map(hObject)

layer=getappdata(hObject,'Layer');
axes_panel_comp=getappdata(hObject,'Axes_panel');
disp_tab=getappdata(hObject,'Display_tab');

curr_disp=getappdata(hObject,'Curr_disp');
[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);

if found==0
    curr_disp.Freq=layer.Frequencies(idx_freq);
end
idx_type=find_type_idx(layer.Transceivers(idx_freq).Data,curr_disp.Type);
min_axis=layer.Transceivers(idx_freq).Data.SubData(idx_type).CaxisDisplay(1);

data=layer.Transceivers(idx_freq).Data.get_datamat(curr_disp.Type);
alpha_map=double(data>=min_axis);


if curr_disp.DispBadTrans
    alpha_map(:,layer.Transceivers(idx_freq).IdxBad)=0.5;
end

[nb_samples,nb_pings]=size(alpha_map);
Range=layer.Transceivers(idx_freq).Data.Range;
Range_mat=repmat(Range,1,nb_pings);
bot_mat=repmat(layer.Transceivers(idx_freq).Bottom.Range,nb_samples,1);

if get(disp_tab.disp_under_bot,'value')==1
    alpha_map(Range_mat>bot_mat)=0;
end


if isa(axes_panel_comp.main_echo,'matlab.graphics.primitive.Surface')
    set(axes_panel_comp.main_echo,'AlphaData',double(alpha_map),'FaceAlpha','flat',...
        'AlphaDataMapping','scaled');
else
    set(axes_panel_comp.main_echo,'AlphaData',double(alpha_map));
end

end