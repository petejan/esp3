function set_alpha_map(hObject)

layer=getappdata(hObject,'Layer');
axes_panel_comp=getappdata(hObject,'Axes_panel');

curr_disp=getappdata(hObject,'Curr_disp');
[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);

if found==0
    curr_disp.Freq=layer.Frequencies(idx_freq);
end
idx_field=find_field_idx(layer.Transceivers(idx_freq).Data,curr_disp.Fieldname);
min_axis=layer.Transceivers(idx_freq).Data.SubData(idx_field).CaxisDisplay(1);

if ~isfield(axes_panel_comp,'main_echo')
    return;
end


data=double(get(axes_panel_comp.main_echo,'CData'));
alpha_map=double(data>=min_axis);

if curr_disp.DispBadTrans
    alpha_map(:,layer.Transceivers(idx_freq).IdxBad)=0.5;
end

[nb_samples,nb_pings]=size(alpha_map);
Range=layer.Transceivers(idx_freq).Data.Range;
Range_mat=repmat(Range,1,nb_pings);
bot_mat=repmat(layer.Transceivers(idx_freq).Bottom.Range,nb_samples,1);

if strcmpi(curr_disp.DispUnderBottom,'off')==1
    alpha_map(Range_mat>bot_mat)=0;
end


if isa(axes_panel_comp.main_echo,'matlab.graphics.primitive.Surface')
    set(axes_panel_comp.main_echo,'AlphaData',double(alpha_map),'FaceAlpha','flat',...
        'AlphaDataMapping','scaled');
else
    set(axes_panel_comp.main_echo,'AlphaData',double(alpha_map));
end

end