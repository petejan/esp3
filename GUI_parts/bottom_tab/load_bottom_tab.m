function load_bottom_tab(main_figure,algo_tab_panel)

if isappdata(main_figure,'Bottom_tab')
    bottom_tab_comp=getappdata(main_figure,'Bottom_tab');
    delete(bottom_tab_comp.bottom_tab);
    rmappdata(main_figure,'Bottom_tab');
end

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
range=layer.Transceivers(idx_freq).Data.Range;



[idx_algo,found]=find_algo_idx(layer.Transceivers(idx_freq),'BottomDetection');

if found==0
    return;
end

algo_obj=layer.Transceivers(idx_freq).Algo(idx_algo);
algo_bottom=algo_obj.Varargin;

bottom_tab_comp.bottom_tab=uitab(algo_tab_panel,'Title','Bottom Detect Option');

pos=create_pos_algo();

uicontrol(bottom_tab_comp.bottom_tab,'Style','Text','String','BS Thr(dB)','units','normalized','Position',pos{1,1});
bottom_tab_comp.Thr_bottom_sl=uicontrol(bottom_tab_comp.bottom_tab,'Style','slider','Min',-50,'Max',-10,'Value',algo_bottom.thr_bottom,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,2});
bottom_tab_comp.Thr_bottom_ed=uicontrol(bottom_tab_comp.bottom_tab,'style','edit','unit','normalized','position',pos{1,3},'string',num2str(get(bottom_tab_comp.Thr_bottom_sl,'Value'),'%.0f'));
set(bottom_tab_comp.Thr_bottom_sl,'callback',{@sync_Sl_ed,bottom_tab_comp.Thr_bottom_ed,'%.0f'});
set(bottom_tab_comp.Thr_bottom_ed,'callback',{@sync_Sl_ed,bottom_tab_comp.Thr_bottom_sl,'%.0f'});

uicontrol(bottom_tab_comp.bottom_tab,'Style','Text','String','Minimum Depth(m)','units','normalized','Position',pos{2,1});
bottom_tab_comp.r_min_sl=uicontrol(bottom_tab_comp.bottom_tab,'Style','slider','Min',range(1),'Max',range(end),'Value',algo_bottom.r_min,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,2});
bottom_tab_comp.r_min_ed=uicontrol(bottom_tab_comp.bottom_tab,'style','edit','unit','normalized','position',pos{2,3},'string',num2str(get(bottom_tab_comp.r_min_sl,'Value'),'%.1f'));
set(bottom_tab_comp.r_min_sl,'callback',{@sync_Sl_ed,bottom_tab_comp.r_min_ed,'%.1f'});
set(bottom_tab_comp.r_min_ed,'callback',{@sync_Sl_ed,bottom_tab_comp.r_min_sl,'%.1f'});


uicontrol(bottom_tab_comp.bottom_tab,'Style','Text','String','Maximum Depth(m)','units','normalized','Position',pos{3,1});
bottom_tab_comp.r_max_sl=uicontrol(bottom_tab_comp.bottom_tab,'Style','slider','Min',range(1),'Max',range(end),'Value',algo_bottom.r_max,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,2});
bottom_tab_comp.r_max_ed=uicontrol(bottom_tab_comp.bottom_tab,'style','edit','unit','normalized','position',pos{3,3},'string',num2str(get(bottom_tab_comp.r_max_sl,'Value'),'%.1f'));
set(bottom_tab_comp.r_max_sl,'callback',{@sync_Sl_ed,bottom_tab_comp.r_max_ed,'%.1f'});
set(bottom_tab_comp.r_max_ed,'callback',{@sync_Sl_ed,bottom_tab_comp.r_max_sl,'%.1f'});

uicontrol(bottom_tab_comp.bottom_tab,'Style','Text','String','Around Echo Thr (dB)','units','normalized','Position',pos{4,1});
bottom_tab_comp.Thr_echo_sl=uicontrol(bottom_tab_comp.bottom_tab,'Style','slider','Min',-20,'Max',-3,'Value',algo_bottom.thr_echo,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{4,2});
bottom_tab_comp.Thr_echo_ed=uicontrol(bottom_tab_comp.bottom_tab,'style','edit','unit','normalized','position',pos{4,3},'string',num2str(get(bottom_tab_comp.Thr_echo_sl,'Value'),'%.0f'));
set(bottom_tab_comp.Thr_echo_sl,'callback',{@sync_Sl_ed,bottom_tab_comp.Thr_echo_ed,'%.0f'});
set(bottom_tab_comp.Thr_echo_ed,'callback',{@sync_Sl_ed,bottom_tab_comp.Thr_echo_sl,'%.0f'});


bottom_tab_comp.denoised=uicontrol(bottom_tab_comp.bottom_tab,'Style','checkbox','Value',algo_bottom.denoised,'String','Compute on Denoised data','units','normalized','Position',[0.5 0.3 0.3 0.1]);

uicontrol(bottom_tab_comp.bottom_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.8 0.1 0.1 0.15],'callback',{@validate,main_figure});
uicontrol(bottom_tab_comp.bottom_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.7 0.1 0.1 0.15],'callback',{@copy_across_algo,main_figure,'BottomDetection'});
uicontrol(bottom_tab_comp.bottom_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.6 0.1 0.1 0.15],'callback',{@save_algos,main_figure});


setappdata(main_figure,'Bottom_tab',bottom_tab_comp);
end


function validate(~,~,main_figure)
update_algos(main_figure);

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
bottom_tab_comp=getappdata(main_figure,'Bottom_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);

idx_algo_bot=find_algo_idx(layer.Transceivers(idx_freq),'BottomDetection');

if isfield(bottom_tab_comp,'denoised')
    if get(bottom_tab_comp.denoised,'Value')>0
        Sv=layer.Transceivers(idx_freq).Data.get_datamat('svdenoised');
        if isempty(Sv)
            Sv=layer.Transceivers(idx_freq).Data.get_datamat('Sv');
        end
    else
        Sv=layer.Transceivers(idx_freq).Data.get_datamat('Sv');
    end
else
    Sv=layer.Transceivers(idx_freq).Data.get_datamat('Sv');
end

algo=layer.Transceivers(idx_freq).Algo(idx_algo_bot);

[Bottom,Double_bottom_region,~,~,~]=feval(algo.Function,Sv,...
    layer.Transceivers(idx_freq).Data.Range,...
    1/layer.Transceivers(idx_freq).Params.SampleInterval(1),...
    layer.Transceivers(idx_freq).Params.PulseLength(1),...
    'thr_bottom',algo.Varargin.thr_bottom,...
    'thr_echo',algo.Varargin.thr_echo,...
    'r_min',algo.Varargin.r_min,...
    'r_max',algo.Varargin.r_max);

range=layer.Transceivers(idx_freq).Data.Range;
bottom_range=nan(size(Bottom));
bottom_range(~isnan(Bottom))=range(Bottom(~isnan(Bottom)));

layer.Transceivers(idx_freq).setBottom(bottom_cl('Origin','Algo_v2',...
    'Range', bottom_range,...
    'Sample_idx',Bottom,...
    'Double_bot_mask',Double_bottom_region));

setappdata(main_figure,'Layer',layer);
load_axis_panel(main_figure,0);

end

