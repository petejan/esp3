function load_school_detect_tab(main_figure,algo_tab_panel)

if isappdata(main_figure,'School_detect_tab')
    school_detect_tab_comp=getappdata(main_figure,'School_detect_tab');
    delete(school_detect_tab_comp.school_detect_tab);
    rmappdata(main_figure,'School_detect_tab');
end

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
range=layer.Transceivers(idx_freq).Data.Range;



[idx_school_detect,found]=find_algo_idx(layer.Transceivers(idx_freq),'SchoolDetection');

if ~found
    return;
end

algo_obj=layer.Transceivers(idx_freq).Algo(idx_school_detect);
algo_school_detect=algo_obj.Varargin;

school_detect_tab_comp.school_detect_tab=uitab(algo_tab_panel,'Title','School Detection');

pos=create_pos_algo();

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Candidate Minimum length(m)','units','normalized','Position',pos{1,1});
school_detect_tab_comp.l_min_can_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',500,'Value',algo_school_detect.l_min_can,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,2});
school_detect_tab_comp.l_min_can_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{1,3},'string',num2str(get(school_detect_tab_comp.l_min_can_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.l_min_can_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.l_min_can_ed,'%.1f'});
set(school_detect_tab_comp.l_min_can_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.l_min_can_sl,'%.1f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Candidate Minimum Heigth(m)','units','normalized','Position',pos{2,1});
school_detect_tab_comp.h_min_can_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',500,'Value',algo_school_detect.h_min_can,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,2});
school_detect_tab_comp.h_min_can_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{2,3},'string',num2str(get(school_detect_tab_comp.h_min_can_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.h_min_can_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.h_min_can_ed,'%.1f'});
set(school_detect_tab_comp.h_min_can_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.h_min_can_sl,'%.1f'});


uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Total Minimum length(m)','units','normalized','Position',pos{3,1});
school_detect_tab_comp.l_min_tot_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',500,'Value',algo_school_detect.l_min_tot,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,2});
school_detect_tab_comp.l_min_tot_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{3,3},'string',num2str(get(school_detect_tab_comp.l_min_tot_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.l_min_tot_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.l_min_tot_ed,'%.1f'});
set(school_detect_tab_comp.l_min_tot_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.l_min_tot_sl,'%.1f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Total Minimum height(m)','units','normalized','Position',pos{4,1});
school_detect_tab_comp.h_min_tot_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',500,'Value',algo_school_detect.h_min_tot,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{4,2});
school_detect_tab_comp.h_min_tot_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{4,3},'string',num2str(get(school_detect_tab_comp.h_min_tot_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.h_min_tot_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.h_min_tot_ed,'%.1f'});
set(school_detect_tab_comp.h_min_tot_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.h_min_tot_sl,'%.1f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','Text','String','Maximum horizontal linking (m)','units','normalized','Position',pos{1,4});
school_detect_tab_comp.horz_link_max_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',500,'Value',algo_school_detect.horz_link_max,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{1,5});
school_detect_tab_comp.horz_link_max_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{1,6},'string',num2str(get(school_detect_tab_comp.horz_link_max_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.horz_link_max_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.horz_link_max_ed,'%.1f'});
set(school_detect_tab_comp.horz_link_max_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.horz_link_max_sl,'%.1f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','text','String','Maximum vertical linking (m)','units','normalized','Position',pos{2,4});
school_detect_tab_comp.vert_link_max_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',20,'Value',algo_school_detect.vert_link_max,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{2,5});
school_detect_tab_comp.vert_link_max_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{2,6},'string',num2str(get(school_detect_tab_comp.vert_link_max_sl,'Value'),'%.1f'));
set(school_detect_tab_comp.vert_link_max_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.vert_link_max_ed,'%.1f'});
set(school_detect_tab_comp.vert_link_max_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.vert_link_max_sl,'%.1f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','text','String','Minimum sample number','units','normalized','Position',pos{3,4});
school_detect_tab_comp.nb_min_sples_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',0,'Max',1000,'Value',algo_school_detect.nb_min_sples,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{3,5});
school_detect_tab_comp.nb_min_sples_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{3,6},'string',num2str(get(school_detect_tab_comp.nb_min_sples_sl,'Value'),'%.0f'));
set(school_detect_tab_comp.nb_min_sples_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.nb_min_sples_ed,'%.0f'});
set(school_detect_tab_comp.nb_min_sples_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.nb_min_sples_sl,'%.0f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','text','String','Sv Threshold (dB)','units','normalized','Position',pos{4,4});
school_detect_tab_comp.sv_thr_sl=uicontrol(school_detect_tab_comp.school_detect_tab,'Style','slider','Min',-120,'Max',-30,'Value',algo_school_detect.Sv_thr,'SliderStep',[0.01 0.1],'units','normalized','Position',pos{4,5});
school_detect_tab_comp.sv_thr_ed=uicontrol(school_detect_tab_comp.school_detect_tab,'style','edit','unit','normalized','position',pos{4,6},'string',num2str(get(school_detect_tab_comp.sv_thr_sl,'Value'),'%.0f'));
set(school_detect_tab_comp.sv_thr_sl,'callback',{@sync_Sl_ed,school_detect_tab_comp.sv_thr_ed,'%.0f'});
set(school_detect_tab_comp.sv_thr_ed,'callback',{@sync_Sl_ed,school_detect_tab_comp.sv_thr_sl,'%.0f'});

uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.8 0.05 0.1 0.1],'callback',{@validate,main_figure});
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.6 0.05 0.1 0.1],'callback',{@copy_across_algo,main_figure,'SchoolDetection'});
uicontrol(school_detect_tab_comp.school_detect_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.4 0.05 0.1 0.1],'callback',{@save_algos,main_figure});


setappdata(main_figure,'School_detect_tab',school_detect_tab_comp);
end







function validate(~,~,main_figure)

update_algos(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

%school_detect_tab_comp=getappdata(main_figure,'School_detect_tab');
region_tab_comp=getappdata(main_figure,'Region_tab');

bottom_tab_comp=getappdata(main_figure,'Bottom_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
idx_school_detect=find_algo_idx(layer.Transceivers(idx_freq),'SchoolDetection');

if isfield(bottom_tab_comp,'denoised')
    if get(bottom_tab_comp.denoised,'Value')>0
        Type='svdenoised';
    else
      Type='sv';
    end
else
    Type='sv';
end


linked_candidates=feval(layer.Transceivers(idx_freq).Algo(idx_school_detect).Function,layer.Transceivers(idx_freq),...
	'Type',Type,...
    'Sv_thr',layer.Transceivers(idx_freq).Algo(idx_school_detect).Varargin.Sv_thr,...
    'l_min_can',layer.Transceivers(idx_freq).Algo(idx_school_detect).Varargin.l_min_can,...
    'h_min_tot',layer.Transceivers(idx_freq).Algo(idx_school_detect).Varargin.h_min_tot,...
    'h_min_can',layer.Transceivers(idx_freq).Algo(idx_school_detect).Varargin.h_min_can,...
    'l_min_tot',layer.Transceivers(idx_freq).Algo(idx_school_detect).Varargin.l_min_tot,...
    'nb_min_sples',layer.Transceivers(idx_freq).Algo(idx_school_detect).Varargin.nb_min_sples,...
    'horz_link_max',layer.Transceivers(idx_freq).Algo(idx_school_detect).Varargin.horz_link_max,...
    'vert_link_max',layer.Transceivers(idx_freq).Algo(idx_school_detect).Varargin.vert_link_max);

layer.Transceivers(idx_freq).rm_region_name('School');

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};

cell_h=str2double(get(region_tab_comp.cell_h,'string'));
cell_w=str2double(get(region_tab_comp.cell_w,'string'));

layer.Transceivers(idx_freq).create_regions_from_linked_candidates(linked_candidates,'w_unit',w_unit,'h_unit',h_unit,'cell_w',cell_w,'cell_h',cell_h);


setappdata(main_figure,'Layer',layer);

update_display(main_figure,0);
end



