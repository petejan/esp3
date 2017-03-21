function create_reg_dlbox(~,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

if isempty(layer)
return;
end
    

reg_fig_comp=getappdata(main_figure,'reg_fig');


reg_fig = new_echo_figure(main_figure,'Units','pixels','Position',[100 100 400 400],'Resize','off',...
    'Name','Create Region',...
    'Tag','create_reg');

uicontrol(reg_fig,'Style','text','BackgroundColor','White',...
    'Units','normalized',...
    'Position',[0.2 0.8 0.6 0.2],...
    'fontsize',14,...
    'String','Create WC Region');

units_w= {'pings','meters'};


units_h={'meters','samples'};
h_unit_idx=1;
w_unit_idx=1;

ref={'Surface','Bottom'};
ref_idx=1;
uicontrol(reg_fig,'Style','Text','BackgroundColor','White','String','Reference','units','normalized','Position',[0 0.7 0.2 0.1]);
reg_fig_comp.tog_ref=uicontrol(reg_fig,'Style','popupmenu','String',ref,'Value',ref_idx,'units','normalized','Position',[0.2 0.7 0.2 0.1]);

switch ref{ref_idx}
    case 'Surface'
     reg_fig_comp.str_surf=uicontrol(reg_fig,'Style','Text','BackgroundColor','White','String','Min Depth(m)','units','normalized','Position',[0 0.6 0.25 0.1]);
    case 'Bottom'
     reg_fig_comp.str_surf=uicontrol(reg_fig,'Style','Text','BackgroundColor','White','String','Height Above Bottom (m)','units','normalized','Position',[0 0.6 0.25 0.1]); 
end
reg_fig_comp.depth_info=uicontrol(reg_fig,'Style','edit','unit','normalized','position',[0.3 0.63 0.1 0.07],'string',5,'Tag','w');


uicontrol(reg_fig,'Style','Text','BackgroundColor','White','String','Cell Width','units','normalized','Position',[0 0.4 0.2 0.1]);
uicontrol(reg_fig,'Style','Text','BackgroundColor','White','String','Cell Height','units','normalized','Position',[0 0.3 0.2 0.1]);


reg_fig_comp.cell_w=uicontrol(reg_fig,'Style','edit','unit','normalized','position',[0.25 0.43 0.1 0.07],'string',10,'Tag','w');
reg_fig_comp.cell_h=uicontrol(reg_fig,'Style','edit','unit','normalized','position',[0.25 0.33 0.1 0.07],'string',10,'Tag','h');

set([reg_fig_comp.cell_w reg_fig_comp.cell_h],'callback',{@check_cell,main_figure})

reg_fig_comp.cell_w_unit=uicontrol(reg_fig,'Style','popupmenu','String',units_w,'Value',w_unit_idx,'units','normalized','Position', [0.4 0.4 0.2 0.1],'Tag','w');
reg_fig_comp.cell_h_unit=uicontrol(reg_fig,'Style','popupmenu','String',units_h,'Value',h_unit_idx,'units','normalized','Position', [0.4 0.3 0.2 0.1],'Tag','h');

data_type={'Data' 'Bad Data'};
data_idx=1;
uicontrol(reg_fig,'Style','Text','String','Data Type','units','normalized','BackgroundColor','White','Position',[0 0.5 0.2 0.1]);
reg_fig_comp.data_type=uicontrol(reg_fig,'Style','popupmenu','String',data_type,'Value',data_idx,'units','normalized','Position', [0.2 0.5 0.2 0.1]);

set(reg_fig_comp.tog_ref,'callback',{@change_ref_callback,reg_fig_comp})
set(reg_fig_comp.depth_info,'callback',@check_depth_info_callback)

uicontrol(reg_fig,'Style','pushbutton','units','normalized',...
    'string','Create Region','pos',[0.5 0.1 0.25,0.1],...
    'TooltipString', 'Create Region',...
    'HorizontalAlignment','left','BackgroundColor','white','callback',{@create_reg_callback,reg_fig_comp,main_figure,reg_fig});



set(reg_fig,'visible','on');
movegui(reg_fig,'center');
end

function create_reg_callback(~,~,reg_fig_comp,main_figure,reg_fig)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');

[idx_freq,found]=find_freq_idx(layer,curr_disp.Freq);

if found==0
    return;
end

trans_obj=layer.Transceivers(idx_freq);



ref=get(reg_fig_comp.tog_ref,'String');
ref_idx=get(reg_fig_comp.tog_ref,'value');

data_type=get(reg_fig_comp.data_type,'String');
data_type_idx=get(reg_fig_comp.data_type,'value');

h_units=get(reg_fig_comp.cell_h_unit,'String');
h_units_idx=get(reg_fig_comp.cell_h_unit,'value');

w_units=get(reg_fig_comp.cell_w_unit,'String');
w_units_idx=get(reg_fig_comp.cell_w_unit,'value');

switch ref{ref_idx}
    case 'Surface'
       y_min=str2double(get(reg_fig_comp.depth_info,'string'));
       y_max=Inf;
    case 'Bottom'
      y_min=str2double(get(reg_fig_comp.depth_info,'string'));
      y_max=0;
end


reg_wc=trans_obj.create_WC_region(...
    'y_min',y_min,...
    'y_max',y_max,...
    'Type',data_type{data_type_idx},...
    'Ref',ref{ref_idx},...
    'Cell_w',str2double(get(reg_fig_comp.cell_w,'string')),...
    'Cell_h',str2double(get(reg_fig_comp.cell_h,'string')),...
    'Cell_w_unit',w_units{w_units_idx},...
    'Cell_h_unit',h_units{h_units_idx});

trans_obj.add_region(reg_wc);
close(reg_fig);

display_regions(main_figure,'both');
set_alpha_map(main_figure);
update_regions_tab(main_figure,length(trans_obj.Regions));
order_stacks_fig(main_figure);
load_region_fig(main_figure,1,[]);

end

function check_depth_info_callback(src,~)
val=str2double(get(src,'String'));
if isnan(val)
    set(src,'string',num2str(5));
end

if val<0
    set(src,'string',num2str(5));
end

end

function change_ref_callback(src,~,reg_fig_comp)

ref=get(reg_fig_comp.tog_ref,'String');
ref_idx=get(reg_fig_comp.tog_ref,'value');

switch ref{ref_idx}
    case 'Surface'
        set(reg_fig_comp.str_surf,'String','Min Depth(m)');
    case 'Bottom'
        set(reg_fig_comp.str_surf,'String','Height Above Bottom (m)');
end
end