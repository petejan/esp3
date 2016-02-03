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
xdata=double(get(axes_panel_comp.main_echo,'XData'));
ydata=double(get(axes_panel_comp.main_echo,'YData'));
alpha_map=double(data>=min_axis);
nb_pings=length(xdata);
nb_samples=length(ydata);

[~,nb_pings_red]=size(alpha_map);
[~,idx_pings]=get_idx_r_n_pings(layer,curr_disp,axes_panel_comp.main_echo);


idx_bad_red=unique(floor(nb_pings_red/nb_pings*(intersect(layer.Transceivers(idx_freq).IdxBad,idx_pings)-idx_pings(1)+1)));
idx_bad_red(idx_bad_red==0)=[];

if curr_disp.DispBadTrans
    alpha_map(:,idx_bad_red)=0.5;
end


Range_mat=repmat(ydata,1,nb_pings);
if ~isempty(layer.Transceivers(idx_freq).Bottom.Range)
    bot_mat=repmat(layer.Transceivers(idx_freq).Bottom.Range(idx_pings),nb_samples,1);
    idx_bot=Range_mat>bot_mat;
    idx_bot_red=imresize(idx_bot,size(alpha_map));
    
    if strcmpi(curr_disp.DispUnderBottom,'off')==1
        alpha_map(idx_bot_red)=0;
    end
end

if isa(axes_panel_comp.main_echo,'matlab.graphics.primitive.Surface')
    set(axes_panel_comp.main_echo,'AlphaData',double(alpha_map),'FaceAlpha','flat',...
        'AlphaDataMapping','scaled');
else
    set(axes_panel_comp.main_echo,'AlphaData',double(alpha_map));
end

end