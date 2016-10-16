function load_denoise_tab(main_figure,algo_tab_panel)

denoise_tab_comp.denoise_tab=uitab(algo_tab_panel,'Title','Denoise');


pos=create_pos_algo_new(5,2);

uicontrol(denoise_tab_comp.denoise_tab,'Style','Text','String','Horizontal Filter (nb pings)','units','normalized','Position',pos{1,1});
denoise_tab_comp.HorzFilt_sl=uicontrol(denoise_tab_comp.denoise_tab,'Style','slider','Min',1,'Max',1,'Value',1,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,2});
denoise_tab_comp.HorzFilt_ed=uicontrol(denoise_tab_comp.denoise_tab,'style','edit','unit','normalized','position',pos{1,3},'string',num2str(get(denoise_tab_comp.HorzFilt_sl,'Value'),'%.0f'));
set(denoise_tab_comp.HorzFilt_sl,'callback',{@sync_Sl_ed,denoise_tab_comp.HorzFilt_ed,'%.0f'});
set(denoise_tab_comp.HorzFilt_ed,'callback',{@sync_Sl_ed,denoise_tab_comp.HorzFilt_sl,'%.0f'});

uicontrol(denoise_tab_comp.denoise_tab,'Style','Text','String','Vertical Filter (m)','units','normalized','Position',pos{2,1});
denoise_tab_comp.VertFilt_sl=uicontrol(denoise_tab_comp.denoise_tab,'Style','slider','Min',1,'Max',1,'Value',1,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,2});
denoise_tab_comp.VertFilt_ed=uicontrol(denoise_tab_comp.denoise_tab,'style','edit','unit','normalized','position',pos{2,3},'string',num2str(get(denoise_tab_comp.VertFilt_sl,'Value'),'%.1f'));
set(denoise_tab_comp.VertFilt_sl,'callback',{@sync_Sl_ed,denoise_tab_comp.VertFilt_ed,'%.1f'});
set(denoise_tab_comp.VertFilt_ed,'callback',{@sync_Sl_ed,denoise_tab_comp.VertFilt_sl,'%.1f'});


uicontrol(denoise_tab_comp.denoise_tab,'Style','Text','String','Noise Level Thr (db)','units','normalized','Position',pos{3,1});
denoise_tab_comp.NoiseThr_sl=uicontrol(denoise_tab_comp.denoise_tab,'Style','slider','Min',-180,'Max',-80,'Value',-120,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,2});
denoise_tab_comp.NoiseThr_ed=uicontrol(denoise_tab_comp.denoise_tab,'style','edit','unit','normalized','position',pos{3,3},'string',num2str(get(denoise_tab_comp.NoiseThr_sl,'Value'),'%.0f'));
set(denoise_tab_comp.NoiseThr_sl,'callback',{@sync_Sl_ed,denoise_tab_comp.NoiseThr_ed,'%.0f'});
set(denoise_tab_comp.NoiseThr_ed,'callback',{@sync_Sl_ed,denoise_tab_comp.NoiseThr_sl,'%.0f'});

uicontrol(denoise_tab_comp.denoise_tab,'Style','Text','String','SNR Thr','units','normalized','Position',pos{4,1});
denoise_tab_comp.SNRThr_sl=uicontrol(denoise_tab_comp.denoise_tab,'Style','slider','Min',0,'Max',30,'Value',10,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{4,2});
denoise_tab_comp.SNRThr_ed=uicontrol(denoise_tab_comp.denoise_tab,'style','edit','unit','normalized','position',pos{4,3},'string',num2str(get(denoise_tab_comp.SNRThr_sl,'Value'),'%.0f'));
set(denoise_tab_comp.SNRThr_sl,'callback',{@sync_Sl_ed,denoise_tab_comp.SNRThr_ed,'%.0f'});
set(denoise_tab_comp.SNRThr_ed,'callback',{@sync_Sl_ed,denoise_tab_comp.SNRThr_sl,'%.0f'});

uicontrol(denoise_tab_comp.denoise_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.8 0.1 0.1 0.15],'callback',{@validate,main_figure});
uicontrol(denoise_tab_comp.denoise_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.7 0.1 0.1 0.15],'callback',{@copy_across_algo,main_figure,'Denoise'});
uicontrol(denoise_tab_comp.denoise_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.6 0.1 0.1 0.15],'callback',{@save_algos,main_figure});


set(findall(denoise_tab_comp.denoise_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Denoise_tab',denoise_tab_comp);

end



function validate(~,~,main_figure)
update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

%profile on;
load_bar_comp=getappdata(main_figure,'Loading_bar');
layer.Transceivers(idx_freq).apply_algo('Denoise','load_bar_comp',load_bar_comp);
% profile off;
% profile viewer;

curr_disp.setField('svdenoised');

setappdata(main_figure,'Layer',layer);
setappdata(main_figure,'Curr_disp',curr_disp);
loadEcho(main_figure);

end
