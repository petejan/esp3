function load_echo_int_tab(main_figure,parent_tab_group)
% import javax.swing.*
% import java.awt.*

switch parent_tab_group.Type
    case 'uitabgroup'
        echo_int_tab_comp.echo_int_tab=new_echo_tab(main_figure,parent_tab_group,'Title','Echo Integration','UiContextMenuName','echoint_tab');
        pos_tab=getpixelposition(echo_int_tab_comp.echo_int_tab);
        pos_tab(4)=pos_tab(4)-30;
    case 'figure'
        echo_int_tab_comp.echo_int_tab=parent_tab_group;
        echo_int_tab_comp.link_props_fig=linkprop([main_figure, parent_tab_group],'AlphaMap');
        pos_tab=getpixelposition(echo_int_tab_comp.echo_int_tab);
end
curr_disp=getappdata(main_figure,'Curr_disp');
layer_obj=getappdata(main_figure,'Layer');

opt_panel_size=[0 pos_tab(4)-550+1 300 550];
ax_panel_size=[opt_panel_size(3) 0 pos_tab(3)-opt_panel_size(3) pos_tab(4)];

echo_int_tab_comp.opt_panel=uipanel(echo_int_tab_comp.echo_int_tab,'units','pixels','BackgroundColor','white','position',opt_panel_size);
echo_int_tab_comp.ax_panel=uipanel(echo_int_tab_comp.echo_int_tab,'units','pixels','BackgroundColor','white','position',ax_panel_size);

[cmap, col_ax, col_lab, col_grid, col_bot, col_txt]=init_cmap(curr_disp.Cmap);
echo_int_tab_comp.main_ax=axes('Parent',echo_int_tab_comp.ax_panel,'Units','Normalized','position',[0.05 0 0.9 0.9],'Color',col_ax,'Layer','top','YTickLabel',{},'XTickLabel',{});
echo_int_tab_comp.v_ax=axes('Parent',echo_int_tab_comp.ax_panel,'Units','Normalized','position',[0 0 0.05 0.9],'YAxisLocation','right','XTickLabel',{});
echo_int_tab_comp.h_ax=axes('Parent',echo_int_tab_comp.ax_panel,'Units','Normalized','position',[0.05 .9 0.9 0.1],'YTickLabel',{});
% echo_int_tab_comp.v_ax.YAxis.TickLabelFormat=' %.0g m';
echo_int_tab_comp.h_ax.XTickLabelRotation=90;

colormap(echo_int_tab_comp.main_ax,cmap);

set([echo_int_tab_comp.h_ax,echo_int_tab_comp.v_ax,echo_int_tab_comp.main_ax],...
    'nextplot','add',...
    'box','on',...
    'GridAlpha',0.2,...
    'XGrid','on',...
    'YGrid','on',...
    'GridLineStyle','--',...
    'GridColor',col_grid,'FontWeight','bold');
colorbar(echo_int_tab_comp.main_ax,'Position',[0.95 0.05 0.02 0.8]);

linkaxes([echo_int_tab_comp.v_ax echo_int_tab_comp.main_ax],'y');
linkaxes([echo_int_tab_comp.h_ax echo_int_tab_comp.main_ax],'x');

echo_int_tab_comp.l_v=linkprop([echo_int_tab_comp.main_ax echo_int_tab_comp.v_ax],'YTick');
echo_int_tab_comp.l_h=linkprop([echo_int_tab_comp.main_ax echo_int_tab_comp.h_ax],'XTick');

axes_panel_comp=getappdata(main_figure,'Axes_panel');

echo_int_tab_comp.l_mv=linkprop([axes_panel_comp.main_axes echo_int_tab_comp.main_ax echo_int_tab_comp.v_ax],'YDir');

echo_int_tab_comp.main_plot=pcolor(echo_int_tab_comp.main_ax,[0 0;0 0],[0 0;0 0],[0 0;0 0]);
echo_int_tab_comp.v_plot=plot(echo_int_tab_comp.v_ax,0,0);
echo_int_tab_comp.h_plot=plot(echo_int_tab_comp.h_ax,0,0);

set(echo_int_tab_comp.main_plot,'facealpha','flat','edgecolor','none','AlphaDataMapping','none');


%%%%%%Option Panel on the left side%%%%
%integration parameters
nb_rows=18;
gui_fmt=init_gui_fmt_struct();
gui_fmt.txt_w=gui_fmt.txt_w*0.8;
pos=create_pos_3(nb_rows,2,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);
uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtTitleStyle,'String','Parameters','Position',pos{1,1}{1}+[0 0 gui_fmt.txt_w 0]);

uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtStyle,'String','Main Chan.','Position',pos{2,1}{1});
echo_int_tab_comp.tog_freq=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.popumenuStyle,'String','--','Value',1,'Position',pos{2,1}{2}+[0 0 gui_fmt.box_w 0]);
curr_disp=init_grid_val(main_figure);
[dx,dy]=curr_disp.get_dx_dy();
uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtStyle,'String','Cell Width','Position',pos{3,1}{1});
echo_int_tab_comp.cell_w=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.edtStyle,'position',pos{3,1}{2},'string',dx,'Tag','w');

uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtStyle,'String','Cell Height','Position',pos{4,1}{1});
echo_int_tab_comp.cell_h=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.edtStyle,'position',pos{4,1}{2},'string',dy,'Tag','h');

if isempty(layer_obj.GPSData.Lat)
    units_w= {'pings','seconds'};
    xaxis_opt={'Ping Number' 'Time'};
else
    units_w= {'meters','pings','seconds'};
    xaxis_opt={'Distance' 'Ping Number' 'Time' 'Lat' 'Long'};
end

units_h={'meters'};
h_unit_idx=find(strcmp('meters',units_h));

w_unit_idx=find(strcmp(curr_disp.Xaxes_current,units_w));

echo_int_tab_comp.cell_w_unit=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.popumenuStyle,'String',units_w,'Value',w_unit_idx,'Position',pos{3,2}{1},'Tag','w');
echo_int_tab_comp.cell_h_unit=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.popumenuStyle,'String',units_h,'Value',h_unit_idx,'Position',pos{4,2}{1},'Tag','h');

echo_int_tab_comp.cell_w_unit_curr=get(echo_int_tab_comp.cell_w_unit,'value');
echo_int_tab_comp.cell_h_unit_curr=get(echo_int_tab_comp.cell_h_unit,'value');

uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtStyle,'String','R min(m)','Position',pos{5,1}{1});
echo_int_tab_comp.r_min=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.edtStyle,'position',pos{5,1}{2},'string',0,'Tag','rmin','callback',{@check_fmt_box,0,Inf,0,'%.1f'});

uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtStyle,'String','R max(m)','Position',pos{6,1}{1});
echo_int_tab_comp.r_max=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.edtStyle,'position',pos{6,1}{2},'string',Inf,'Tag','rmax','callback',{@check_fmt_box,0,Inf,Inf,'%.1f'});



set([echo_int_tab_comp.cell_w echo_int_tab_comp.cell_h],'callback',{@check_cell,main_figure,echo_int_tab_comp})
set(echo_int_tab_comp.cell_w_unit ,'callback',{@tog_units,main_figure,echo_int_tab_comp});
set(echo_int_tab_comp.cell_h_unit ,'callback',{@tog_units,main_figure,echo_int_tab_comp});

gui_fmt=init_gui_fmt_struct();
gui_fmt.txt_w=gui_fmt.txt_w*1.4;
pos=create_pos_3(nb_rows,2,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.txt_w,gui_fmt.box_h);

echo_int_tab_comp.denoised=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.chckboxStyle,'Value',0,'String','Denoised data','Position',pos{7,1}{1});
echo_int_tab_comp.motion_corr=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.chckboxStyle,'Value',0,'String','Motion Correction','Position',pos{7,1}{2});
echo_int_tab_comp.shadow_zone=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.chckboxStyle,'Value',0,'String','Shadow zone Est. (m)','Position',pos{7,1}{1},'visible','off');
echo_int_tab_comp.shadow_zone_h=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.edtStyle,'position',pos{7,1}{2}+[0 0 gui_fmt.box_w-gui_fmt.txt_w 0],'string','10','callback',{@ check_fmt_box,0,inf,10,'%.1f'},'visible','off');
echo_int_tab_comp.rm_st=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.chckboxStyle,'Value',0,'String','Rm.Single Targets','Position',pos{8,1}{1});
echo_int_tab_comp.all_freq=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.chckboxStyle,'Value',0,'String','All Frequencies','Position',pos{8,1}{2});

echo_int_tab_comp.reg_only=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.chckboxStyle,'Value',1,'String','Integrate by','Position',pos{9,1}{1},'Tooltipstring','unchecked: integrate all WC within bounds');
int_opt={'Tag' 'ID' 'Name' 'All Data Regions'};
echo_int_tab_comp.tog_int=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.popumenuStyle,'String',int_opt,'Value',1,'Position',pos{9,1}{2}-[0 0 gui_fmt.txt_w/3 0]);
uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtStyle,'position',pos{10,1}{1},'string','Region specs: ');
echo_int_tab_comp.reg_id_box=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.edtStyle,'position',pos{10,1}{2}-[0 0 gui_fmt.txt_w/3 0],'string','');

p_button=pos{11,1}{1};
p_button(3)=gui_fmt.button_w;
uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.pushbtnStyle,'String','Compute','pos',p_button,'callback',{@slice_transect_cback,main_figure})
uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.pushbtnStyle,'String','Export','pos',p_button+[gui_fmt.button_w 0 0 0],'callback',{@export_cback,main_figure})

set(echo_int_tab_comp.echo_int_tab,'ResizeFcn',{@resize_echo_int_cback,main_figure});


%display part
init_disp=13;
uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtTitleStyle,'String','Display','Position',pos{init_disp,1}{1});
ref={'Surface','Bottom'};
ref_idx=find(strcmp(ref,'Surface'));
uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtStyle,'String','Reference ','Position',pos{init_disp+1,1}{1}-[0 0 gui_fmt.txt_w/2 0]);
echo_int_tab_comp.tog_ref=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.popumenuStyle,'String',ref,'Value',ref_idx,'Position',pos{init_disp+1,1}{1}+[gui_fmt.txt_w/2 0 -gui_fmt.txt_w/2 0],'callback',{@update_cback,main_figure});
uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtStyle,'String','Data ','Position',pos{init_disp+2,1}{1}-[0 0 gui_fmt.txt_w/2 0]);
echo_int_tab_comp.tog_type=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.popumenuStyle,'String',{'Sv' 'PRC' 'Std Sv' 'Nb Samples'},'Value',1,'Position',pos{init_disp+2,1}{1}+[gui_fmt.txt_w/2 0 -gui_fmt.txt_w/2 0],'callback',{@update_cback,main_figure});
echo_int_tab_comp.tog_tfreq=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.popumenuStyle,'String',{'--'},'Value',1,'Position',pos{init_disp+2,1}{2}-[0 0 gui_fmt.txt_w/2 0],'callback',{@update_cback,main_figure});
uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.txtStyle,'String','X-Axis ','Position',pos{init_disp+3,1}{1}-[0 0 gui_fmt.txt_w/2 0]);

echo_int_tab_comp.tog_xaxis=uicontrol(echo_int_tab_comp.opt_panel,gui_fmt.popumenuStyle,'String',xaxis_opt,...
    'Value',2,'Position',pos{init_disp+3,1}{1}+[ gui_fmt.txt_w/2 0 0 0],'callback',{@update_cback,main_figure});

%axes_panel_comp=getappdata(main_figure,'Axes_panel');
% echo_int_tab_comp.link_props_m=linkprop([axes_panel_comp.main_axes echo_int_tab_comp.main_ax ],{'YColor','XColor','GridLineStyle','Color','Clim','GridColor','MinorGridColor','YDir'});
% echo_int_tab_comp.link_props_h=linkprop([axes_panel_comp.main_axes echo_int_tab_comp.h_ax],{'YColor','XColor','GridLineStyle','Color','Clim','GridColor','MinorGridColor'});
% echo_int_tab_comp.link_props_v=linkprop([axes_panel_comp.main_axes echo_int_tab_comp.v_ax],{'YColor','XColor','GridLineStyle','Color','Clim','GridColor','MinorGridColor','YDir'});
setappdata(main_figure,'EchoInt_tab',echo_int_tab_comp);

update_echo_int_tab(main_figure,1);

end
function update_cback(src,evt,main_figure)
update_echo_int_tab(main_figure,0);
end

function slice_transect_cback(src,evt,main_figure)

echo_int_tab_comp=getappdata(main_figure,'EchoInt_tab');
layer_obj=getappdata(main_figure,'Layer');

idx_main=get(echo_int_tab_comp.tog_freq,'value');

[trans_obj,idx_freq]=layer_obj.get_trans(layer_obj.ChannelID{idx_main});
reg_type=echo_int_tab_comp.reg_id_box.String;
reg_types=strsplit(reg_type,';');

switch echo_int_tab_comp.tog_int.String{echo_int_tab_comp.tog_int.Value}
    case 'All Data Regions'
        idx_reg=trans_obj.find_regions_type('Data');
    case 'ID'
        reg_types=str2double(reg_types);
        idx_reg=trans_obj.find_regions_ID(reg_types);
    case 'Tag'
        idx_reg=trans_obj.find_regions_tag(reg_types);
    case 'Name'
        idx_reg=trans_obj.find_regions_name(reg_types);
end

show_status_bar(main_figure);

Slice_w=str2double(echo_int_tab_comp.cell_w.String);
Slice_w_u=echo_int_tab_comp.cell_w_unit.String{echo_int_tab_comp.cell_w_unit.Value};
Slice_h=str2double(echo_int_tab_comp.cell_h.String);

if echo_int_tab_comp.all_freq.Value>0
    idx_sec=1:numel(layer_obj.Frequencies);
else
    idx_sec=idx_main;
end

[layer_obj.EchoIntStruct.output_2D_surf_tot,...
    layer_obj.EchoIntStruct.output_2D_bot_tot,...
    layer_obj.EchoIntStruct.regs_tot,...
    layer_obj.EchoIntStruct.regCellInt_tot,...
    layer_obj.EchoIntStruct.reg_descr_table,...
    layer_obj.EchoIntStruct.output_2D_sh_tot,...
    layer_obj.EchoIntStruct.shz_height_est,...
    layer_obj.EchoIntStruct.idx_freq_out]=layer_obj.multi_freq_slice_transect2D(...
    'idx_main_freq',idx_main,...
    'idx_sec_freq',idx_sec,...
    'idx_regs',idx_reg,...
    'regs',region_cl.empty(),...
    'Slice_w',Slice_w,...
    'Slice_w_units',Slice_w_u,...
    'Slice_h',Slice_h,...
    'StartTime',0,...
    'EndTime',Inf,...
    'Denoised',echo_int_tab_comp.denoised.Value,...
    'Motion_correction',echo_int_tab_comp.motion_corr.Value,...
    'Shadow_zone',echo_int_tab_comp.shadow_zone.Value,...
    'Shadow_zone_height',str2double(echo_int_tab_comp.shadow_zone_h.String),...
    'DepthMin',str2double(echo_int_tab_comp.r_min.String),...
    'DepthMax',str2double(echo_int_tab_comp.r_max.String),...
    'RegInt',0,...
    'Remove_ST',echo_int_tab_comp.rm_st.Value,...
    'intersect_only',echo_int_tab_comp.reg_only.Value,...
    'load_bar_comp',getappdata(main_figure,'Loading_bar'));

layer_obj.EchoIntStruct.params=struct('Cell_w',Slice_w,'Cell_h',Slice_h,'Cell_w_unit',Slice_w_u,'Cell_h_unit','meters');

hide_status_bar(main_figure);
freqs_out=layer_obj.Frequencies(layer_obj.EchoIntStruct.idx_freq_out);
idx_main=find(layer_obj.Frequencies(idx_freq)==freqs_out);
set(echo_int_tab_comp.tog_tfreq,'String',num2str(freqs_out'/1e3,'%.0f kHz'),'Value',idx_main);
setappdata(main_figure,'EchoInt_tab',echo_int_tab_comp);

update_echo_int_tab(main_figure,0);
end

function export_cback(src,evt,main_figure)
echo_int_tab_comp=getappdata(main_figure,'EchoInt_tab');
idx_main_freq=get(echo_int_tab_comp.tog_freq,'value');
layer_obj=getappdata(main_figure,'Layer');

if isempty(layer_obj.EchoIntStruct)
    return;
end

layer=getappdata(main_figure,'Layer');
if isempty(layer)
    return;
end

[path_tmp,fileN,~]=fileparts(layer.Filename{1});

path_tmp = uigetdir(path_tmp,...
    'Save Sliced transect to folder');
if isequal(path_tmp,0)
    return;
end

idx_main=idx_main_freq==layer_obj.EchoIntStruct.idx_freq_out;
% regCellInt=layer_obj.EchoIntStruct.regCellInt_tot{idx_main};
% regs=layer_obj.EchoIntStruct.regs_tot{idx_main};

if ~isempty(layer_obj.EchoIntStruct.reg_descr_table) 
    output_f=[fullfile(path_tmp,fileN) '_regions_descr.csv'];   
    if exist(output_f,'file')>1
        delete(output_f);
    end
    writetable(layer_obj.EchoIntStruct.reg_descr_table,output_f);
end

output_f=[fullfile(path_tmp,fileN) '_surf_sliced_transect.csv'];
reg_output_table=reg_output_to_table(layer_obj.EchoIntStruct.output_2D_surf_tot{idx_main});
writetable(reg_output_table,output_f);

if ~isempty(layer_obj.EchoIntStruct.output_2D_bot_tot{idx_main})
    output_f=[fullfile(path_tmp,fileN) '_bot_sliced_transect.csv'];
    reg_output_table=reg_output_to_table(layer_obj.EchoIntStruct.output_2D_bot_tot{idx_main});
    writetable(reg_output_table,output_f);
end

if ~isempty(layer_obj.EchoIntStruct.output_2D_sh_tot{idx_main})
    output_f=[fullfile(path_tmp,fileN) '_sh_sliced_transect.csv'];
    reg_output_table=reg_output_to_table(layer_obj.EchoIntStruct.output_2D_sh_tot{idx_main});
    writetable(reg_output_table,output_f);
end

end

function resize_echo_int_cback(src,~,main_figure)
echo_int_tab_comp=getappdata(main_figure,'EchoInt_tab');

switch echo_int_tab_comp.echo_int_tab.Type
    case 'uitab'
        pos_tab=getpixelposition(echo_int_tab_comp.echo_int_tab);
        pos_tab(4)=pos_tab(4)-30;
    case 'figure'
        pos_tab=getpixelposition(echo_int_tab_comp.echo_int_tab);
end
opt_panel_size=[0 pos_tab(4)-550+1 300 550];
ax_panel_size=[opt_panel_size(3) 0 pos_tab(3)-opt_panel_size(3) pos_tab(4)];
set(echo_int_tab_comp.opt_panel,'position',opt_panel_size);
set(echo_int_tab_comp.ax_panel,'position',ax_panel_size);
end