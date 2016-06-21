function load_bad_pings_tab(main_figure,algo_tab_panel)

if isappdata(main_figure,'Bad_ping_tab')
    bad_ping_tab_comp=getappdata(main_figure,'Bad_ping_tab');
    delete(bad_ping_tab_comp.bad_ping_tab);
    rmappdata(main_figure,'Bad_ping_tab');
end

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
range=layer.Transceivers(idx_freq).Data.get_range();



[~,found_bot]=find_algo_idx(layer.Transceivers(idx_freq),'BottomDetection');
[idx_bad_pings,found_bp]=find_algo_idx(layer.Transceivers(idx_freq),'BadPings');

if ~found_bot||~found_bp
    return;
end

algo_obj=layer.Transceivers(idx_freq).Algo(idx_bad_pings);
algo_bad_pings=algo_obj.Varargin;

bad_ping_tab_comp.bad_ping_tab=uitab(algo_tab_panel,'Title','Bad Transmit');

pos=create_pos_algo();

uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','Text','String','BS Thr(dB)','units','normalized','Position',pos{1,1});
bad_ping_tab_comp.Thr_bottom_sl=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','slider','Min',-50,'Max',-10,'Value',algo_bad_pings.thr_bottom,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,2});
bad_ping_tab_comp.Thr_bottom_ed=uicontrol(bad_ping_tab_comp.bad_ping_tab,'style','edit','unit','normalized','position',pos{1,3},'string',num2str(get(bad_ping_tab_comp.Thr_bottom_sl,'Value'),'%.0f'));
set(bad_ping_tab_comp.Thr_bottom_sl,'callback',{@sync_Sl_ed,bad_ping_tab_comp.Thr_bottom_ed,'%.0f'});
set(bad_ping_tab_comp.Thr_bottom_ed,'callback',{@sync_Sl_ed,bad_ping_tab_comp.Thr_bottom_sl,'%.0f'});

uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','Text','String','Minimum Depth(m)','units','normalized','Position',pos{2,1});
bad_ping_tab_comp.r_min_sl=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','slider','Min',range(1),'Max',range(end),'Value',nanmax(algo_bad_pings.r_min,range(1)),'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,2});
bad_ping_tab_comp.r_min_ed=uicontrol(bad_ping_tab_comp.bad_ping_tab,'style','edit','unit','normalized','position',pos{2,3},'string',num2str(get(bad_ping_tab_comp.r_min_sl,'Value'),'%.1f'));
set(bad_ping_tab_comp.r_min_sl,'callback',{@sync_Sl_ed,bad_ping_tab_comp.r_min_ed,'%.1f'});
set(bad_ping_tab_comp.r_min_ed,'callback',{@sync_Sl_ed,bad_ping_tab_comp.r_min_sl,'%.1f'});


uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','Text','String','Maximum Depth(m)','units','normalized','Position',pos{3,1});
bad_ping_tab_comp.r_max_sl=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','slider','Min',range(1),'Max',range(end),'Value',nanmin(algo_bad_pings.r_max,range(end)),'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,2});
bad_ping_tab_comp.r_max_ed=uicontrol(bad_ping_tab_comp.bad_ping_tab,'style','edit','unit','normalized','position',pos{3,3},'string',num2str(get(bad_ping_tab_comp.r_max_sl,'Value'),'%.1f'));
set(bad_ping_tab_comp.r_max_sl,'callback',{@sync_Sl_ed,bad_ping_tab_comp.r_max_ed,'%.1f'});
set(bad_ping_tab_comp.r_max_ed,'callback',{@sync_Sl_ed,bad_ping_tab_comp.r_max_sl,'%.1f'});

uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','Text','String','Around Echo Thr (dB)','units','normalized','Position',pos{4,1});
bad_ping_tab_comp.Thr_echo_sl=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','slider','Min',-20,'Max',-3,'Value',algo_bad_pings.thr_echo,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{4,2});
bad_ping_tab_comp.Thr_echo_ed=uicontrol(bad_ping_tab_comp.bad_ping_tab,'style','edit','unit','normalized','position',pos{4,3},'string',num2str(get(bad_ping_tab_comp.Thr_echo_sl,'Value'),'%.0f'));
set(bad_ping_tab_comp.Thr_echo_sl,'callback',{@sync_Sl_ed,bad_ping_tab_comp.Thr_echo_ed,'%.0f'});
set(bad_ping_tab_comp.Thr_echo_ed,'callback',{@sync_Sl_ed,bad_ping_tab_comp.Thr_echo_sl,'%.0f'});

bad_ping_tab_comp.Above=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','checkbox','Value',algo_bad_pings.Above,'String','Above bottom PDF threshold (%)','units','normalized','Position',pos{1,4});
bad_ping_tab_comp.thr_spikes_Above_sl=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','slider','Min',0,'Max',20,'Value',algo_bad_pings.thr_spikes_Above,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,5});
bad_ping_tab_comp.thr_spikes_Above_ed=uicontrol(bad_ping_tab_comp.bad_ping_tab,'style','edit','unit','normalized','position',pos{1,6},'string',num2str(get(bad_ping_tab_comp.thr_spikes_Above_sl,'Value'),'%.0f'));
set(bad_ping_tab_comp.thr_spikes_Above_sl,'callback',{@sync_Sl_ed,bad_ping_tab_comp.thr_spikes_Above_ed,'%.0f'});
set(bad_ping_tab_comp.thr_spikes_Above_ed,'callback',{@sync_Sl_ed,bad_ping_tab_comp.thr_spikes_Above_sl,'%.0f'});

bad_ping_tab_comp.Below=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','checkbox','Value',algo_bad_pings.Below,'String','Below bottom PDF threshold (%)','units','normalized','Position',pos{2,4});
bad_ping_tab_comp.thr_spikes_Below_sl=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','slider','Min',0,'Max',20,'Value',algo_bad_pings.thr_spikes_Below,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,5});
bad_ping_tab_comp.thr_spikes_Below_ed=uicontrol(bad_ping_tab_comp.bad_ping_tab,'style','edit','unit','normalized','position',pos{2,6},'string',num2str(get(bad_ping_tab_comp.thr_spikes_Below_sl,'Value'),'%.0f'));
set(bad_ping_tab_comp.thr_spikes_Below_sl,'callback',{@sync_Sl_ed,bad_ping_tab_comp.thr_spikes_Below_ed,'%.0f'});
set(bad_ping_tab_comp.thr_spikes_Below_ed,'callback',{@sync_Sl_ed,bad_ping_tab_comp.thr_spikes_Below_sl,'%.0f'});


bad_ping_tab_comp.BS_std_bool=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','checkbox','Value',algo_bad_pings.BS_std_bool,'String','BS fluctuation limit (dB)','units','normalized','Position',pos{3,4});
bad_ping_tab_comp.BS_std_sl=uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','slider','Min',3,'Max',20,'Value',algo_bad_pings.BS_std,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,5});
bad_ping_tab_comp.BS_std_ed=uicontrol(bad_ping_tab_comp.bad_ping_tab,'style','edit','unit','normalized','position',pos{3,6},'string',num2str(get(bad_ping_tab_comp.BS_std_sl,'Value'),'%.0f'));
set(bad_ping_tab_comp.BS_std_sl,'callback',{@sync_Sl_ed,bad_ping_tab_comp.BS_std_ed,'%.0f'});
set(bad_ping_tab_comp.BS_std_ed,'callback',{@sync_Sl_ed,bad_ping_tab_comp.BS_std_sl,'%.0f'});

uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.7 0.1 0.1 0.15],'callback',{@copy_across_algo,main_figure,'BadPings'});
uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.8 0.1 0.1 0.15],'callback',{@validate,main_figure});
uicontrol(bad_ping_tab_comp.bad_ping_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.6 0.1 0.1 0.15],'callback',{@save_algos,main_figure});

setappdata(main_figure,'Bad_ping_tab',bad_ping_tab_comp);
end



function validate(~,~,main_figure)

update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');


idx_freq=find_freq_idx(layer,curr_disp.Freq);

% profile on;

layer.Transceivers(idx_freq).apply_algo('BadPings');

% 
% profile off;
% profile viewer;


setappdata(main_figure,'Layer',layer);
load_axis_panel(main_figure,0);

end
