function fix_ylim(src,~,main_figure,tab_tag)
multi_freq_disp_tab_comp=getappdata(main_figure,tab_tag);

if multi_freq_disp_tab_comp.ax_lim_cbox.Value>0
    cax_ori=get(multi_freq_disp_tab_comp.ax,'YLim');
    cax=str2double(get([multi_freq_disp_tab_comp.thr_down multi_freq_disp_tab_comp.thr_up],'String'));
    if cax(2)<cax(1)||isnan(cax(1))||isnan(cax(2))
        cax=cax_ori;
    end
    set(multi_freq_disp_tab_comp.thr_up,'String',num2str(cax(2),'%.0f'));
    set(multi_freq_disp_tab_comp.thr_down,'String',num2str(cax(1),'%.0f'));
    ylim(multi_freq_disp_tab_comp.ax,cax);
else
    ylim(multi_freq_disp_tab_comp.ax,'auto');
    cax=get(multi_freq_disp_tab_comp.ax,'YLim');
    set(multi_freq_disp_tab_comp.thr_up,'String',num2str(cax(2),'%.0f'));
    set(multi_freq_disp_tab_comp.thr_down,'String',num2str(cax(1),'%.0f'));
end

end