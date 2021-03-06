function update_secondary_freq_win(main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
if curr_disp.DispSecFreqs<=0
    return;
end
if ~isdeployed
    disp('Update Secondary Freq Window');
end

if ~isappdata(main_figure,'Secondary_freq')
    load_secondary_freq_win(main_figure);
    return;
end

layer=getappdata(main_figure,'Layer');

if isempty(layer)
    return;
end

secondary_freq=getappdata(main_figure,'Secondary_freq');

curr_disp=getappdata(main_figure,'Curr_disp');

axes_panel_comp=getappdata(main_figure,'Axes_panel');
x=double(get(axes_panel_comp.main_axes,'xlim'));
y=double(get(axes_panel_comp.main_axes,'ylim'));
nb_chan=numel(curr_disp.SecChannelIDs);

for i=1:nb_chan
    
    echo_obj=findobj(secondary_freq.axes(i),{'Type','image','-and','Tag',curr_disp.SecChannelIDs{i}});
    if ~isempty(echo_obj)
        struct_temp.ChannelID=curr_disp.SecChannelIDs{i};
        struct_temp.Freq=curr_disp.SecFreqs(i);
        trans_obj=layer.get_trans(struct_temp);
        range=trans_obj.get_transceiver_range();
        dr=nanmean(diff(range));
        y1=(curr_disp.R_disp(1)-range(1))/dr;
        y2=(curr_disp.R_disp(2)-range(1))/dr;

        layer.display_layer(struct_temp,curr_disp.Fieldname,secondary_freq.axes(i),echo_obj,x,[y1 y2],0);
    end
end

end