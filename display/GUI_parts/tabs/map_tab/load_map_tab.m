function load_map_tab(main_figure,tab_panel,varargin)

p = inputParser;
addRequired(p,'main_figure',@(obj) isa(obj,'matlab.ui.Figure'));
addRequired(p,'tab_panel',@(obj) ishghandle(obj));
addParameter(p,'cont_disp',0,@isnumeric);
addParameter(p,'cont_val',500,@isnumeric);
addParameter(p,'coast_disp',0,@isnumeric);
addParameter(p,'idx_lays',[],@isnumeric);
addParameter(p,'all_lays',0,@isnumeric);
parse(p,main_figure,tab_panel,varargin{:});

map_tab_comp.idx_lays=p.Results.idx_lays;


switch tab_panel.Type
    case 'uitabgroup'
        map_tab_comp.map_tab=new_echo_tab(main_figure,tab_panel,'Title','Map','UiContextMenuName','map');
    case 'figure'
        map_tab_comp.map_tab=tab_panel;
end

set(map_tab_comp.map_tab,'ResizeFcn',{@resize_map_tab,main_figure})

size_tab=getpixelposition(map_tab_comp.map_tab);

height=nanmin(size_tab(4)-20,200);
size_opt=[10 size_tab(4)-height 190 height];
ax_size=[size_opt(3)+size_opt(1) 0 size_tab(3)-size_opt(3) size_tab(4)];
map_tab_comp.opt_panel=uibuttongroup(map_tab_comp.map_tab,'units','pixels','Position',size_opt,'Title','Options','background','white');

gui_fmt=init_gui_fmt_struct();
gui_fmt.txt_w=gui_fmt.txt_w*2;
pos=create_pos_3(5,2,gui_fmt.x_sep,gui_fmt.y_sep,gui_fmt.txt_w,gui_fmt.box_w,gui_fmt.box_h);
%
%  uicontrol(...
% 'Parent',multi_freq_tab.setting_panel,...
% 'String','Diap',...
% gui_fmt.txtTitleStyle,...
% 'Position',pos{1,2}{1}+[0 0 gui_fmt.box_w 0],...
% 'Callback','');

map_tab_comp.cont_disp=p.Results.cont_disp;
map_tab_comp.cont_val=p.Results.cont_val;
map_tab_comp.idx_lays=p.Results.idx_lays;
map_tab_comp.coast_disp=p.Results.coast_disp;
map_tab_comp.all_lays=p.Results.all_lays;

map_tab_comp.cont_checkbox=uicontrol(...
    'Parent',map_tab_comp.opt_panel,...
    'String','Contours(m)',...
    gui_fmt.chckboxStyle,...
    'Position',pos{1,1}{1},...
    'Callback',{@update_map_cback,main_figure},'Value',p.Results.cont_disp);

map_tab_comp.contour_edit_box=uicontrol(...
    'Parent',map_tab_comp.opt_panel,...
    'String',num2str(p.Results.cont_val),...
    gui_fmt.edtStyle,...
    'Position',pos{1,1}{2},...
    'Callback',{@update_map_cback,main_figure});

map_tab_comp.coast_checkbox=uicontrol(...
    'Parent',map_tab_comp.opt_panel,...
    'String','Coastline',...
    gui_fmt.chckboxStyle,...
    'Position',pos{2,1}{1},...
    'Callback',{@update_map_cback,main_figure},'Value',p.Results.coast_disp);

map_tab_comp.rad_curr=uicontrol(...
    'Parent',map_tab_comp.opt_panel,...
    'String','Current Layer',...
    gui_fmt.radbtnStyle,...
    'Position',pos{3,1}{1},...
    'Callback',{@update_map_cback,main_figure},'Value',p.Results.all_lays==0);

map_tab_comp.rad_all=uicontrol(...
    'Parent',map_tab_comp.opt_panel,...
    'String','All Layers',...
    gui_fmt.radbtnStyle,...
    'Position',pos{4,1}{1},...
    'Callback',{@update_map_cback,main_figure},'Value',p.Results.all_lays>0);


map_tab_comp.ax=axes('Parent',map_tab_comp.map_tab,'Units','pixels','box','on',...
    'OuterPosition',ax_size,'visible','off','NextPlot','add','box','on');

map_tab_comp.boat_pos=[];
map_tab_comp.tracks_plots=[];
map_tab_comp.map_info=[];
map_tab_comp.contour_plots=[];
map_tab_comp.h_contour_plots=[];
map_tab_comp.coast_plot=[];
map_tab_comp.h_coast_plot=[];

setappdata(main_figure,'Map_tab',map_tab_comp);

update_map_tab(main_figure);

end

function resize_map_tab(src,evt,main_figure)
map_tab_comp=getappdata(main_figure,'Map_tab');
size_tab=getpixelposition(map_tab_comp.map_tab);
height=nanmin(size_tab(4)-20,200);
size_opt=[10 size_tab(4)-height 190 height];
ax_size=[size_opt(3)+size_opt(1) 0 size_tab(3)-size_opt(3) size_tab(4)];

set(map_tab_comp.opt_panel,'Position',size_opt);
set(map_tab_comp.ax,'OuterPosition',ax_size);


end

function update_map_cback(src,evt,main_figure)

update_map_tab(main_figure,'src',src);

end
