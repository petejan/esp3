function update_multi_freq_disp_tab(main_figure)
layer=getappdata(main_figure,'Layer');
if isempty(layer) 
    return;
end
curr_disp=getappdata(main_figure,'Curr_disp');
multi_freq_disp_tab_comp=getappdata(main_figure,'multi_freq_disp_tab');
set(multi_freq_disp_tab_comp.ax,'visible','on');




end
