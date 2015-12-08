function load_single_target_tab(main_figure,algo_tab_panel)

if isappdata(main_figure,'Single_target_tab')
    single_target_tab_comp=getappdata(main_figure,'Single_target_tab');
    delete(single_target_tab_comp.single_target_tab);
    rmappdata(main_figure,'Single_target_tab');
end

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);


[idx_single_target,found]=find_algo_idx(layer.Transceivers(idx_freq),'SingleTarget');

if ~found
    return;
end

algo_obj=layer.Transceivers(idx_freq).Algo(idx_single_target);
algo_single_target=algo_obj.Varargin;

single_target_tab_comp.single_target_tab=uitab(algo_tab_panel,'Title','Single Target Detection');

pos=create_pos_algo();

uicontrol(single_target_tab_comp.single_target_tab,'Style','Text','String','TS Threshold (dB)','units','normalized','Position',pos{1,1});
single_target_tab_comp.TS_threshold_sl=uicontrol(single_target_tab_comp.single_target_tab,'Style','slider','Min',-120,'Max',-20,'Value',algo_single_target.TS_threshold,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,2});
single_target_tab_comp.TS_threshold_ed=uicontrol(single_target_tab_comp.single_target_tab,'style','edit','unit','normalized','position',pos{1,3},'string',num2str(get(single_target_tab_comp.TS_threshold_sl,'Value'),'%.0f'));
set(single_target_tab_comp.TS_threshold_sl,'callback',{@sync_Sl_ed,single_target_tab_comp.TS_threshold_ed,'%.0f'});
set(single_target_tab_comp.TS_threshold_ed,'callback',{@sync_Sl_ed,single_target_tab_comp.TS_threshold_sl,'%.0f'});

uicontrol(single_target_tab_comp.single_target_tab,'Style','Text','String','PLDL','units','normalized','Position',pos{2,1});
single_target_tab_comp.PLDL_sl=uicontrol(single_target_tab_comp.single_target_tab,'Style','slider','Min',6,'Max',30,'Value',algo_single_target.PLDL,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,2});
single_target_tab_comp.PLDL_ed=uicontrol(single_target_tab_comp.single_target_tab,'style','edit','unit','normalized','position',pos{2,3},'string',num2str(get(single_target_tab_comp.PLDL_sl,'Value'),'%.0f'));
set(single_target_tab_comp.PLDL_sl,'callback',{@sync_Sl_ed,single_target_tab_comp.PLDL_ed,'%.0f'});
set(single_target_tab_comp.PLDL_ed,'callback',{@sync_Sl_ed,single_target_tab_comp.PLDL_sl,'%.0f'});


uicontrol(single_target_tab_comp.single_target_tab,'Style','Text','String','Minimum Norm Echo Length','units','normalized','Position',pos{3,1});
single_target_tab_comp.MinNormPL_sl=uicontrol(single_target_tab_comp.single_target_tab,'Style','slider','Min',0,'Max',10,'Value',algo_single_target.MinNormPL,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,2});
single_target_tab_comp.MinNormPL_ed=uicontrol(single_target_tab_comp.single_target_tab,'style','edit','unit','normalized','position',pos{3,3},'string',num2str(get(single_target_tab_comp.MinNormPL_sl,'Value'),'%.1f'));
set(single_target_tab_comp.MinNormPL_sl,'callback',{@sync_Sl_ed,single_target_tab_comp.MinNormPL_ed,'%.1f'});
set(single_target_tab_comp.MinNormPL_ed,'callback',{@sync_Sl_ed,single_target_tab_comp.MinNormPL_sl,'%.1f'});

uicontrol(single_target_tab_comp.single_target_tab,'Style','Text','String','Max Norm Echo Length','units','normalized','Position',pos{4,1});
single_target_tab_comp.MaxNormPL_sl=uicontrol(single_target_tab_comp.single_target_tab,'Style','slider','Min',0,'Max',10,'Value',algo_single_target.MaxNormPL,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{4,2});
single_target_tab_comp.MaxNormPL_ed=uicontrol(single_target_tab_comp.single_target_tab,'style','edit','unit','normalized','position',pos{4,3},'string',num2str(get(single_target_tab_comp.MaxNormPL_sl,'Value'),'%.1f'));
set(single_target_tab_comp.MaxNormPL_sl,'callback',{@sync_Sl_ed,single_target_tab_comp.MaxNormPL_ed,'%.1f'});
set(single_target_tab_comp.MaxNormPL_ed,'callback',{@sync_Sl_ed,single_target_tab_comp.MaxNormPL_sl,'%.1f'});

uicontrol(single_target_tab_comp.single_target_tab,'Style','Text','String','Maximum Beam Compensation','units','normalized','Position',pos{1,4});
single_target_tab_comp.MaxBeamComp_sl=uicontrol(single_target_tab_comp.single_target_tab,'Style','slider','Min',3,'Max',18,'Value',algo_single_target.MaxBeamComp,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,5});
single_target_tab_comp.MaxBeamComp_ed=uicontrol(single_target_tab_comp.single_target_tab,'style','edit','unit','normalized','position',pos{1,6},'string',num2str(get(single_target_tab_comp.MaxBeamComp_sl,'Value'),'%.0f'));
set(single_target_tab_comp.MaxBeamComp_sl,'callback',{@sync_Sl_ed,single_target_tab_comp.MaxBeamComp_ed,'%.0f'});
set(single_target_tab_comp.MaxBeamComp_ed,'callback',{@sync_Sl_ed,single_target_tab_comp.MaxBeamComp_sl,'%.0f'});

uicontrol(single_target_tab_comp.single_target_tab,'Style','text','String','Max AlongShip angle phase std','units','normalized','Position',pos{2,4});
single_target_tab_comp.MaxStdMinAxisAngle_sl=uicontrol(single_target_tab_comp.single_target_tab,'Style','slider','Min',0,'Max',30,'Value',algo_single_target.MaxStdMinAxisAngle,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,5});
single_target_tab_comp.MaxStdMinAxisAngle_ed=uicontrol(single_target_tab_comp.single_target_tab,'style','edit','unit','normalized','position',pos{2,6},'string',num2str(get(single_target_tab_comp.MaxStdMinAxisAngle_sl,'Value'),'%.1f'));
set(single_target_tab_comp.MaxStdMinAxisAngle_sl,'callback',{@sync_Sl_ed,single_target_tab_comp.MaxStdMinAxisAngle_ed,'%.1f'});
set(single_target_tab_comp.MaxStdMinAxisAngle_ed,'callback',{@sync_Sl_ed,single_target_tab_comp.MaxStdMinAxisAngle_sl,'%.1f'});

uicontrol(single_target_tab_comp.single_target_tab,'Style','text','String','Max AcrossShip angle phase std','units','normalized','Position',pos{3,4});
single_target_tab_comp.MaxStdMajAxisAngle_sl=uicontrol(single_target_tab_comp.single_target_tab,'Style','slider','Min',0,'Max',30,'Value',algo_single_target.MaxStdMajAxisAngle,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,5});
single_target_tab_comp.MaxStdMajAxisAngle_ed=uicontrol(single_target_tab_comp.single_target_tab,'style','edit','unit','normalized','position',pos{3,6},'string',num2str(get(single_target_tab_comp.MaxStdMajAxisAngle_sl,'Value'),'%.1f'));
set(single_target_tab_comp.MaxStdMajAxisAngle_sl,'callback',{@sync_Sl_ed,single_target_tab_comp.MaxStdMajAxisAngle_ed,'%.1f'});
set(single_target_tab_comp.MaxStdMajAxisAngle_ed,'callback',{@sync_Sl_ed,single_target_tab_comp.MaxStdMajAxisAngle_sl,'%.1f'});


uicontrol(single_target_tab_comp.single_target_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.8 0.05 0.1 0.1],'callback',{@validate,main_figure});
uicontrol(single_target_tab_comp.single_target_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.6 0.05 0.1 0.1],'callback',{@copy_across_algo,main_figure,'SingleTarget'});
uicontrol(single_target_tab_comp.single_target_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.4 0.05 0.1 0.1],'callback',{@save_algos,main_figure});


setappdata(main_figure,'Single_target_tab',single_target_tab_comp);
end



function validate(~,~,main_figure)

update_algos(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
%axes_panel_comp=getappdata(main_figure,'Axes_panel');
%single_target_tab_comp=getappdata(main_figure,'Single_target_tab');
%region_tab_comp=getappdata(main_figure,'Region_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
idx_single_target=find_algo_idx(layer.Transceivers(idx_freq),'SingleTarget');


ST=feval(layer.Transceivers(idx_freq).Algo(idx_single_target).Function,layer.Transceivers(idx_freq),...
    'Type',layer.Transceivers(idx_freq).Algo(idx_single_target).Varargin.Type,...
    'TS_threshold',layer.Transceivers(idx_freq).Algo(idx_single_target).Varargin.TS_threshold,...
    'PLDL',layer.Transceivers(idx_freq).Algo(idx_single_target).Varargin.PLDL,...
    'MinNormPL',layer.Transceivers(idx_freq).Algo(idx_single_target).Varargin.MinNormPL,...
    'MaxNormPL',layer.Transceivers(idx_freq).Algo(idx_single_target).Varargin.MaxNormPL,...
    'MaxBeamComp',layer.Transceivers(idx_freq).Algo(idx_single_target).Varargin.MaxBeamComp,...
    'MaxStdMinAxisAngle',layer.Transceivers(idx_freq).Algo(idx_single_target).Varargin.MaxStdMinAxisAngle,...
    'MaxStdMajAxisAngle',layer.Transceivers(idx_freq).Algo(idx_single_target).Varargin.MaxStdMajAxisAngle,...
    'DataType',layer.Transceivers(idx_freq).Mode);

layer.Transceivers(idx_freq).set_ST(ST);

layer.Transceivers(idx_freq).Tracks=struct('target_id',{},'target_ping_number',{});
curr_disp.setField('singletarget');
setappdata(main_figure,'Layer',layer);
    

end




