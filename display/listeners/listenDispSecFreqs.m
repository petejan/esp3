function listenDispSecFreqs(~,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

switch curr_disp.DispSecFreqs
    case 1
        load_secondary_freq_win(main_figure);
        update_cmap(main_figure);
        set_alpha_map(main_figure,'main_or_mini',union({'main','mini'},layer.ChannelID));
        reverse_y_axis(main_figure);
        display_bottom(main_figure);
    case 0
        if isappdata(main_figure,'Secondary_freq')
            secondary_freq=getappdata(main_figure,'Secondary_freq');
            delete(secondary_freq.fig);
            rmappdata(main_figure,'Secondary_freq');
        end
end

display_tab_comp=getappdata(main_figure,'Display_tab');
if ~isempty(display_tab_comp)
    display_tab_comp.sec_freq_disp.Value=curr_disp.DispSecFreqs;
end


end