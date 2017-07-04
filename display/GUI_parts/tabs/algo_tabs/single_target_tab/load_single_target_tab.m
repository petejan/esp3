function load_single_target_tab(main_figure,algo_tab_panel)

single_target_tab_comp.single_target_tab=uitab(algo_tab_panel,'Title','Single Targets');


algo=algo_cl('Name','SingleTarget');
varin=algo.Varargin;

x_ini=0.0;
y_ini=1;
x_sep=0.02;
y_sep=0.02;

pos=create_pos_2(4,2,x_ini,y_ini,x_sep,y_sep);

parameters_1=uipanel(single_target_tab_comp.single_target_tab,'title','','Position',[0.01 0.2 0.3 0.7],'fontsize',11);

uicontrol(parameters_1,'Style','text','units','normalized','string','TS thr(dB)','pos',pos{1,1},'HorizontalAlignment','right');
single_target_tab_comp.TS_threshold=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(varin.TS_threshold),'BackgroundColor','white','callback',{@ check_fmt_box,-120,-10,varin.TS_threshold,'%.0f'});

uicontrol(parameters_1,'Style','text','units','normalized','string','PLDL(dB)','pos',pos{2,1},'HorizontalAlignment','right');
single_target_tab_comp.PLDL=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(varin.PLDL),'BackgroundColor','white','callback',{@ check_fmt_box,1,12,varin.PLDL,'%.0f'});

uicontrol(parameters_1,'Style','text','units','normalized','string','Min Norm PL','pos',pos{3,1},'HorizontalAlignment','right');
single_target_tab_comp.MinNormPL=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(varin.MinNormPL),'BackgroundColor','white','callback',{@ check_fmt_box,0.2,2,varin.MinNormPL,'%.1f'});

uicontrol(parameters_1,'Style','text','units','normalized','string','Max Norm PL','pos',pos{4,1},'HorizontalAlignment','right');
single_target_tab_comp.MaxNormPL=uicontrol(parameters_1,'Style','Edit','units','normalized','pos',pos{4,2},'string',num2str(varin.MaxNormPL),'BackgroundColor','white','callback',{@ check_fmt_box,0.2,2,varin.MaxNormPL,'%.1f'});

parameters_2=uipanel(single_target_tab_comp.single_target_tab,'title','','Position',[0.32 0.2 0.32 0.7],'fontsize',11);

uicontrol(parameters_2,'Style','text','units','normalized','string','Max. Beam Comp.','pos',pos{1,1},'HorizontalAlignment','right');
single_target_tab_comp.MaxBeamComp=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{1,2},'string',num2str(varin.MaxBeamComp),'BackgroundColor','white','callback',{@ check_fmt_box,3,18,varin.MaxBeamComp,'%.0f'});

uicontrol(parameters_2,'Style','text','units','normalized','string',[char(hex2dec('0394')) ' Along Angle(' char(hex2dec('00B0')) ')'],'pos',pos{2,1},'HorizontalAlignment','right');
single_target_tab_comp.MaxStdMinAxisAngle=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{2,2},'string',num2str(varin.MaxStdMinAxisAngle),'BackgroundColor','white','callback',{@ check_fmt_box,0,45,varin.MaxStdMinAxisAngle,'%.1f'});

uicontrol(parameters_2,'Style','text','units','normalized','string',[char(hex2dec('0394')) ' Across Angle(' char(hex2dec('00B0')) ')'],'pos',pos{3,1},'HorizontalAlignment','right');
single_target_tab_comp.MaxStdMajAxisAngle=uicontrol(parameters_2,'Style','Edit','units','normalized','pos',pos{3,2},'string',num2str(varin.MaxStdMajAxisAngle),'BackgroundColor','white','callback',{@ check_fmt_box,0,45,varin.MaxStdMajAxisAngle,'%.1f'});

single_target_tab_comp.ax_pos=axes('Parent',single_target_tab_comp.single_target_tab,'Units','normalized','box','off',...
    'OuterPosition',[0.6 0 0.4 1],'visible','off','NextPlot','add','box','on','tag','st_ax');

uicontrol(single_target_tab_comp.single_target_tab,'Style','pushbutton','String','Apply','units','normalized','pos',[0.55 0.1 0.1 0.12],'callback',{@validate,main_figure});
uicontrol(single_target_tab_comp.single_target_tab,'Style','pushbutton','String','Copy','units','normalized','pos',[0.45 0.1 0.1 0.12],'callback',{@copy_across_algo,main_figure,'SingleTarget'});
uicontrol(single_target_tab_comp.single_target_tab,'Style','pushbutton','String','Save','units','normalized','pos',[0.35 0.1 0.1 0.12],'callback',{@save_algos,main_figure});

%set(findall(single_target_tab_comp.single_target_tab, '-property', 'Enable'), 'Enable', 'off');
setappdata(main_figure,'Single_target_tab',single_target_tab_comp);
end



function validate(~,~,main_figure)

update_algos(main_figure);
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

show_status_bar(main_figure);
load_bar_comp=getappdata(main_figure,'Loading_bar');
layer.Transceivers(idx_freq).apply_algo('SingleTarget','load_bar_comp',load_bar_comp);

hide_status_bar(main_figure);

curr_disp.setField('singletarget');
curr_disp.Freq=curr_disp.Freq;
setappdata(main_figure,'Curr_disp',curr_disp);
update_single_target_tab(main_figure,0);
end




