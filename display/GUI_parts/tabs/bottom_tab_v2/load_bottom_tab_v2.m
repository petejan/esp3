function load_bottom_tab_v2(main_figure,algo_tab_panel)

bottom_tab_v2_comp.bottom_tab=uitab(algo_tab_panel,'Title','Bottom Detect Option V2');

pos=create_pos_algo_new(5,2);

uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','Text','String','BS Thr(dB)','units','normalized','Position',pos{1,1});
bottom_tab_v2_comp.Thr_bottom_sl=uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','slider','Min',-80,'Max',-10,'Value',-35,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,2});
bottom_tab_v2_comp.Thr_bottom_ed=uicontrol(bottom_tab_v2_comp.bottom_tab,'style','edit','unit','normalized','position',pos{1,3},'string',num2str(get(bottom_tab_v2_comp.Thr_bottom_sl,'Value'),'%.0f'));
set(bottom_tab_v2_comp.Thr_bottom_sl,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.Thr_bottom_ed,'%.0f'});
set(bottom_tab_v2_comp.Thr_bottom_ed,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.Thr_bottom_sl,'%.0f'});

uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','Text','String','Minimum Depth(m)','units','normalized','Position',pos{2,1});
bottom_tab_v2_comp.r_min_sl=uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','slider','Min',0,'Max',1,'Value',0,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,2});
bottom_tab_v2_comp.r_min_ed=uicontrol(bottom_tab_v2_comp.bottom_tab,'style','edit','unit','normalized','position',pos{2,3},'string',num2str(get(bottom_tab_v2_comp.r_min_sl,'Value'),'%.1f'));
set(bottom_tab_v2_comp.r_min_sl,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.r_min_ed,'%.1f'});
set(bottom_tab_v2_comp.r_min_ed,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.r_min_sl,'%.1f'});


uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','Text','String','Maximum Depth(m)','units','normalized','Position',pos{3,1});
bottom_tab_v2_comp.r_max_sl=uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','slider','Min',0,'Max',1,'Value',1,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,2});
bottom_tab_v2_comp.r_max_ed=uicontrol(bottom_tab_v2_comp.bottom_tab,'style','edit','unit','normalized','position',pos{3,3},'string',num2str(get(bottom_tab_v2_comp.r_max_sl,'Value'),'%.1f'));
set(bottom_tab_v2_comp.r_max_sl,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.r_max_ed,'%.1f'});
set(bottom_tab_v2_comp.r_max_ed,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.r_max_sl,'%.1f'});

uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','Text','String','Backstep Thr (dB)','units','normalized','Position',pos{4,1});
bottom_tab_v2_comp.Thr_backstep_sl=uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','slider','Min',-12,'Max',12,'Value',-1,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{4,2});
bottom_tab_v2_comp.Thr_backstep_ed=uicontrol(bottom_tab_v2_comp.bottom_tab,'style','edit','unit','normalized','position',pos{4,3},'string',num2str(get(bottom_tab_v2_comp.Thr_backstep_sl,'Value'),'%.0f'));
set(bottom_tab_v2_comp.Thr_backstep_sl,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.Thr_backstep_ed,'%.0f'});
set(bottom_tab_v2_comp.Thr_backstep_ed,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.Thr_backstep_sl,'%.0f'});

uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','Text','String','Thr Around Echo (dB)','units','normalized','Position',pos{1,4});
bottom_tab_v2_comp.thr_echo_sl=uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','slider','Min',-80,'Max',-3,'Value',-40,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,5});
bottom_tab_v2_comp.thr_echo_ed=uicontrol(bottom_tab_v2_comp.bottom_tab,'style','edit','unit','normalized','position',pos{1,6},'string',num2str(get(bottom_tab_v2_comp.thr_echo_sl,'Value'),'%.0f'));
set(bottom_tab_v2_comp.thr_echo_sl,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.thr_echo_ed,'%.0f'});
set(bottom_tab_v2_comp.thr_echo_ed,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.thr_echo_sl,'%.0f'});


uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','Text','String','Cumulative Thr','units','normalized','Position',pos{2,4},'Tooltipstring','Higher for harder bottom.');
bottom_tab_v2_comp.thr_cum_sl=uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','slider','Min',0,'Max',1,'Value',0.01,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,5});
bottom_tab_v2_comp.thr_cum_ed=uicontrol(bottom_tab_v2_comp.bottom_tab,'style','edit','unit','normalized','position',pos{2,6},'string',num2str(get(bottom_tab_v2_comp.thr_cum_sl,'Value'),'%.2f'));
set(bottom_tab_v2_comp.thr_cum_sl,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.thr_cum_ed,'%.2f'});
set(bottom_tab_v2_comp.thr_cum_ed,'callback',{@sync_Sl_ed,bottom_tab_v2_comp.thr_cum_sl,'%.2f'});


uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','Text','String','Shift Bottom up(m)','units','normalized','Position',pos{3,4});
bottom_tab_v2_comp.Shift_bot_sl=uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','slider','Min',-50,'Max',50,'Value',0,'SliderStep',[0.005 0.01],'units','normalized','Position',pos{3,5});
bottom_tab_v2_comp.Shift_bot_ed=uicontrol(bottom_tab_v2_comp.bottom_tab,'style','edit','unit','normalized','position',pos{3,6},'string',num2str(get(bottom_tab_v2_comp.Shift_bot_sl,'Value'),'%.1f'));
set(bottom_tab_v2_comp.Shift_bot_sl,'callback',@(src,evtdata)(cellfun(@(x)feval(x,src,evtdata),...
    {@(src,evtdata) sync_Sl_ed(src,evtdata,bottom_tab_v2_comp.Shift_bot_ed,'%.1f'),...
    @(src,evtdata) shift_bottom_callback_v2(src,evtdata,main_figure)})));
set(bottom_tab_v2_comp.Shift_bot_ed,'callback',@(src,evtdata)(cellfun(@(x)feval(x,src,evtdata),...
    {@(src,evtdata) sync_Sl_ed(src,evtdata,bottom_tab_v2_comp.Shift_bot_sl,'%.1f'),...
    @(src,evtdata) shift_bottom_callback_v2(src,evtdata,main_figure)})));

bottom_tab_v2_comp.denoised=uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','checkbox','Value',0,'String','Compute on Denoised data','units','normalized','Position',[0.7 0.3 0.3 0.1]);

uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.8 0.1 0.1 0.15],'callback',{@validate,main_figure});
uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.7 0.1 0.1 0.15],'callback',{@copy_across_algo,main_figure,'BottomDetection'});
uicontrol(bottom_tab_v2_comp.bottom_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.6 0.1 0.1 0.15],'callback',{@save_algos,main_figure});

set(findall(bottom_tab_v2_comp.bottom_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Bottom_tab_v2',bottom_tab_v2_comp);
end


function validate(~,~,main_figure)
update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
layer.Transceivers(idx_freq).apply_algo('BottomDetectionV2','load_bar_comp',load_bar_comp);

hide_status_bar(main_figure);

setappdata(main_figure,'Layer',layer);
set_alpha_map(main_figure);
set_alpha_map(main_figure,'main_or_mini','mini');
display_bottom(main_figure);
order_stacks_fig(main_figure);

end

