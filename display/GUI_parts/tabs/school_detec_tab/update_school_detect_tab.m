function update_school_detect_tab(main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
school_detect_tab_comp=getappdata(main_figure,'School_detect_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'SchoolDetection');
if found==0
     return
end

algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo=algo_obj.Varargin;


set(school_detect_tab_comp.l_min_can_sl,'value',algo.l_min_can);
set(school_detect_tab_comp.l_min_can_ed,'string',num2str(get(school_detect_tab_comp.l_min_can_sl,'Value'),'%.1f'));

set(school_detect_tab_comp.h_min_can_sl,'value',algo.h_min_can);
set(school_detect_tab_comp.h_min_can_ed,'string',num2str(get(school_detect_tab_comp.h_min_can_sl,'Value'),'%.1f'));

set(school_detect_tab_comp.l_min_tot_sl,'value',algo.l_min_tot);
set(school_detect_tab_comp.l_min_tot_ed,'string',num2str(get(school_detect_tab_comp.l_min_tot_sl,'Value'),'%.1f'));

set(school_detect_tab_comp.h_min_tot_sl,'value',algo.h_min_tot);
set(school_detect_tab_comp.h_min_tot_ed,'string',num2str(get(school_detect_tab_comp.h_min_tot_sl,'Value'),'%.1f'));

set(school_detect_tab_comp.horz_link_max_sl,'value',algo.horz_link_max);
set(school_detect_tab_comp.horz_link_max_ed,'string',num2str(get(school_detect_tab_comp.horz_link_max_sl,'Value'),'%.1f'));

set(school_detect_tab_comp.vert_link_max_sl,'value',algo.vert_link_max);
set(school_detect_tab_comp.vert_link_max_ed,'string',num2str(get(school_detect_tab_comp.vert_link_max_sl,'Value'),'%.1f'));

set(school_detect_tab_comp.nb_min_sples_sl,'value',algo.nb_min_sples);
set(school_detect_tab_comp.nb_min_sples_ed,'string',num2str(get(school_detect_tab_comp.nb_min_sples_sl,'Value'),'%.0f'));

set(school_detect_tab_comp.sv_thr_sl,'value',algo.Sv_thr);
set(school_detect_tab_comp.sv_thr_ed,'string',num2str(get(school_detect_tab_comp.sv_thr_sl,'Value'),'%.0f'));

set(findall(school_detect_tab_comp.school_detect_tab, '-property', 'Enable'), 'Enable', 'on');

setappdata(main_figure,'School_detect_tab',school_detect_tab_comp);

end
