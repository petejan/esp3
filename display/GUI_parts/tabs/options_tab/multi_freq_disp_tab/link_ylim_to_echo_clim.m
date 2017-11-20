function link_ylim_to_echo_clim(~,~,main_figure,tab_tag)
multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);
curr_disp=getappdata(main_figure,'Curr_disp');
switch tab_tag
    case 'sv_f'
        field='sv';
    case 'ts_f'
        field='sp';
end

if multi_freq_disp_tab_comp.ax_lim_cbox.Value>0
    ylim(multi_freq_disp_tab_comp.ax,curr_disp.getCaxField(field));
else
    ylim(multi_freq_disp_tab_comp.ax,'auto');
end

end