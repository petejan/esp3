function update_multi_freq_tab(main_figure)

multi_freq_tab=getappdata(main_figure,'multi_freq_tab');
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,~]=find_freq_idx(layer,curr_disp.Freq);

%trans_obj=trans_obj;

set(multi_freq_tab.primary_freq,'String',layer.Frequencies,'value',idx_freq);
set(multi_freq_tab.secondary_freqs,'String',layer.Frequencies,'value',1);


setappdata(main_figure,'multi_freq_tab',multi_freq_tab);