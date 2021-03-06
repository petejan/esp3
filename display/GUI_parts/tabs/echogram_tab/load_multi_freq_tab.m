function load_multi_freq_tab(main_figure,parent_tab_group)

multi_freq_tab.parent_tab=uitab(parent_tab_group,'Title','Multi Freq','BackgroundColor','white');
multi_freq_tab.setting_panel=uipanel(multi_freq_tab.parent_tab,'Position',[0 0 1 1]);
%multi_freq_tab.disp_panel=uipanel(multi_freq_tab.parent_tab,'Position',[0.15 0 0.85 1]);

gui_fmt=init_gui_fmt_struct();

pos=create_pos_3(6,3,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);
p_button=pos{5,3}{1};

 uicontrol(...
'Parent',multi_freq_tab.setting_panel,...
'String','Primary Channel',...
gui_fmt.txtTitleStyle,...
'Position',pos{1,1}{1}+[0 0 gui_fmt.box_w 0],...
'Callback','');

multi_freq_tab.primary_freq = uicontrol(...
'Parent',multi_freq_tab.setting_panel,...
'String',{'--'},...
gui_fmt.popumenuStyle,...
'Value',1,...
'Position',pos{2,1}{1},...
'Callback','',...
'Tag','primary_freq');

 uicontrol(...
'Parent',multi_freq_tab.setting_panel,...
'String','Secondary Channels',...
gui_fmt.txtTitleStyle,...
'Position',pos{1,2}{1}+[0 0 gui_fmt.box_w 0],...
'Callback','');

multi_freq_tab.secondary_freqs = uicontrol(...
'Parent',multi_freq_tab.setting_panel,...
'String',{'--'},...
gui_fmt.lstboxStyle,...
'max',10,...
'Position',pos{5,2}{1}+[0 0 0 pos{2,2}{1}(2)-pos{5,2}{1}(2)],...
'Callback','',...
'Tag','secondary_freqs');

 uicontrol(...
'Parent',multi_freq_tab.setting_panel,...
'String','Sub-sampling',...
gui_fmt.txtTitleStyle,...
'Position',pos{1,3}{1}+[0 0 gui_fmt.box_w 0],...
'Callback','');

uicontrol(multi_freq_tab.setting_panel,gui_fmt.txtStyle,'String','Pings:','Position',pos{2,3}{1});
multi_freq_tab.grid_pings=uicontrol(multi_freq_tab.setting_panel,gui_fmt.edtStyle,'position',pos{2,3}{2},'string','5');

uicontrol(multi_freq_tab.setting_panel,gui_fmt.txtStyle,'String','Samples:','Position',pos{3,3}{1});
multi_freq_tab.grid_samples=uicontrol(multi_freq_tab.setting_panel,gui_fmt.edtStyle,'position',pos{3,3}{2},'string','5');

set([multi_freq_tab.grid_pings multi_freq_tab.grid_samples],'callback',{@check_fmt_box,0,inf,5,'%.0f'})

 uicontrol(...
'Parent',multi_freq_tab.setting_panel,...
'String','Threshold(dB)',...
gui_fmt.txtStyle,...
'Position',pos{4,3}{1});

multi_freq_tab.db_threshold=uicontrol(multi_freq_tab.setting_panel,gui_fmt.edtStyle,'position',pos{4,3}{2},'string','-75');

set(multi_freq_tab.db_threshold ,'callback',{@check_fmt_box,-999,-30,-75,'%.0f'})


uicontrol(...
    'Parent',multi_freq_tab.setting_panel,...
    gui_fmt.pushbtnStyle,...
    'String','Update',...
    'callback',{@compute_freq_diff_cback,main_figure},...
    'position',p_button);

setappdata(main_figure,'multi_freq_tab',multi_freq_tab);
end

function compute_freq_diff_cback(src,evtdata,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
if isempty(layer)
    return;
end
multi_freq_tab=getappdata(main_figure,'multi_freq_tab');

primary_freq=layer.Frequencies(multi_freq_tab.primary_freq.Value);
secondary_freqs=layer.Frequencies(multi_freq_tab.secondary_freqs.Value);
secondary_freqs=setdiff(secondary_freqs,primary_freq);

if isempty(secondary_freqs)
    return;
end

[secondary_freqs,cax,~]=layer.generate_freq_differences('primary_freq',primary_freq,'secondary_freqs',secondary_freqs,...
    'Cell_h',str2double(multi_freq_tab.grid_samples.String),'Cell_w',str2double(multi_freq_tab.grid_pings.String),'sv_thr',str2double(multi_freq_tab.db_threshold.String));
if isempty(secondary_freqs)
    return;
end
curr_disp.ChannelID=layer.ChannelID{layer.Frequencies==primary_freq};

curr_disp.setField(sprintf('Sv%.0fkHz',secondary_freqs(end)/1e3));
curr_disp.setCax(cax(end,:));
setappdata(main_figure,'Curr_disp',curr_disp);
update_display_tab(main_figure);

   
end