
function load_map_fig(main_fig,obj_vec,varargin)

p = inputParser;

addRequired(p,'main_fig',@ishandle);
addRequired(p,'obj_vec',@(obj) isa(obj,'mbs_cl')||isa(obj,'survey_cl')||isempty(obj));

parse(p,main_fig,obj_vec,varargin{:});


if isempty(obj_vec)
    layers=getappdata(main_fig,'Layers');
    [box.lat_box,box.lon_box,box.lat_lays,box.lon_lays]=get_lat_lon_lim(layers);
    list_Str=list_layers(layers);
else
    [box.lat_box,box.lon_box,box.lat_lays,box.lon_lays]=get_lat_lon_lim(obj_vec);
    switch class(obj_vec)
        case 'mbs_cl'
            list_Str=list_mbs(obj_vec);
        case 'survey_cl'
            list_Str=list_survey(obj_vec);
    end
end
box.lat_lim=[nan nan];
box.lon_lim=[nan nan];


[box.lat_lim,box.lon_lim]=ext_lat_lon_lim(box.lat_box,box.lon_box,0.1);

if nansum(isnan(box.lat_lim))==2
    return;
end

box.slice_size=10;
box.val_max=0.000001;
box.r_max=2;
box.nb_pts=100;
proj=m_getproj;
box.list_proj_str={proj(:).name};
box.proj_idx=8;
box.proj=box.list_proj_str{box.proj_idx};
box.depth_contour_size=100;


map_fig =new_echo_figure(main_fig,'Units','pixels','Position',[100 100 800 600],...
    'Resize','off',...
    'Name','Map');

box.lim_axes=axes('Parent', map_fig,...
    'FontSize',9,...
    'Units','normalized',...
    'OuterPosition',[0 0.2 0.7 0.8],...
    'visible','off',...
    'Tag','map');

uicontrol(map_fig,'Style','text','BackgroundColor','White',...
    'Units','normalized',...
    'Position',[0.7 0.92 0.25 0.05],...
    'fontsize',14,...
    'BackgroundColor','w',...
    'String','Select Layers:');
box.listbox = uicontrol(map_fig,'Style','listbox',...
    'Units','normalized',...
    'Position',[0.7 0.5 0.25 0.4],...
    'String',list_Str,...
    'BackgroundColor','w',...
    'Max',2,...
    'Tag','listbox',...
    'Callback',{@update_map_callback,map_fig});

switch class(obj_vec)
    case 'mbs_cl'
        field_str={'SliceAbscf'};
    case 'survey_cl'
        field_str={'SliceAbscf','Nb_ST','Nb_Tracks','Tag'};
    otherwise
        field_str={'SliceAbscf','Nb_ST','Nb_Tracks'};
end


type_str={'Log10', 'Square Root', 'Linear'};

uicontrol(map_fig,'Style','text','BackgroundColor','White',...
    'Units','normalized',...
    'Position',[0.3 0.15 0.25 0.05],...
    'BackgroundColor','w',...
    'String','Variable to plot and scale:');
box.field = uicontrol(map_fig,'Style','popupmenu',...
    'Units','normalized',...
    'Position',[0.3 0.1 0.2 0.05],...
    'String',field_str,...
    'Callback',{@update_field_callback,map_fig});
        
box.plottype = uicontrol(map_fig,'Style','popupmenu',...
    'Units','normalized',...
    'Position',[0.3 0.025 0.2 0.05],...
    'String',type_str);


box.tog_proj=uicontrol(map_fig,'Style','popupmenu','String',box.list_proj_str,'Value',box.proj_idx,...
    'units','normalized','Position', [0.7 0.4 0.25 0.05],'Callback',{@init_map,map_fig});

box.coast_box=uicontrol(map_fig,'Style','checkbox','Value',1,...
    'String','Display Coast','units','normalized','Position',[0.7 0.3 0.2 0.05],...
    'BackgroundColor','w',...
    'callback',{@update_map_callback,map_fig});

box.depth_box=uicontrol(map_fig,'Style','checkbox','Value',1,...
    'String','Depth Contours every (m)','units','normalized','Position',[0.6 0.2 0.25 0.05],...
    'BackgroundColor','w',...
    'callback',{@update_map_callback,map_fig});

box.depth_contour_box = uicontrol(map_fig,'Style','edit',...
    'Units','normalized',...
    'Position',[0.85 0.2 0.1 0.05],...
    'String',num2str(box.depth_contour_size,'%d'),...
    'BackgroundColor','w',...
    'Tag','slice_size','Callback',{@check_depth_contour_size,map_fig});


uicontrol(map_fig,'Style','text','BackgroundColor','White',...
    'Units','normalized',...
    'Position',[0.025 0.175 0.125 0.05],...
    'BackgroundColor','w',...
    'String','Slice (pings):');
box.slice_size_box = uicontrol(map_fig,'Style','edit',...
    'Units','normalized',...
    'Position',[0.175 0.175 0.1 0.05],...
    'String',num2str(box.slice_size,'%d'),...
    'BackgroundColor','w',...
    'Tag','slice_size','Callback',{@check_slice_size,map_fig});

if ~isempty(obj_vec)
    set(box.slice_size_box,'enable','off');
    switch class(obj_vec)
        case 'survey_cl'
            set(box.slice_size_box,'String',num2str(obj_vec(1).SurvInput.Options.Vertical_slice_size,'%d'));
        case 'mbs_cl'
            
    end
end

str_field=get(box.field,'string');
str_field=str_field{get(box.field,'value')};

box.str_field=uicontrol(map_fig,'Style','text','BackgroundColor','White',...
    'Units','normalized',...
    'BackgroundColor','w',...
    'Position',[0.025 0.1 0.125 0.05],...
    'String',sprintf('%s',str_field));
box.val_max_box = uicontrol(map_fig,'Style','edit',...
    'Units','normalized',...
    'Position',[0.175 0.1 0.1 0.05],...
    'String',num2str(box.val_max,'%.8g'),...
    'BackgroundColor','w',...
    'Tag','slice_size','Callback',{@check_val_max,map_fig});

uicontrol(map_fig,'Style','text','BackgroundColor','White',...
    'Units','normalized',...
    'Position',[0.025 0.025 0.125 0.05],...
    'BackgroundColor','w',...
    'String','R(km):');
box.r_max_box = uicontrol(map_fig,'Style','edit',...
    'Units','normalized',...
    'Position',[0.175 0.025 0.1 0.05],...
    'String',num2str(box.r_max,'%.2f'),...
    'BackgroundColor','w',...
    'Tag','slice_size','Callback',{@check_r_max,map_fig});

uicontrol(map_fig,'Style','pushbutton','units','normalized',...
    'string','Create Map','pos',[0.7 0.1 0.1 0.05],...
    'TooltipString', 'Create Map',...
    'HorizontalAlignment','left','BackgroundColor','white','callback',{@create_map_callback,map_fig,main_fig,obj_vec});


setappdata(map_fig,'Box',box);
init_map([],[],map_fig);
set(map_fig,'visible','on')
end

function init_map(~,~,map_fig)
box=getappdata(map_fig,'Box');
box.proj_idx=get(box.tog_proj,'value');
box.proj=box.list_proj_str{box.proj_idx};
cont=box.depth_contour_size;

[lon,lat]=create_box(box.lon_box,box.lat_box,box.nb_pts);
axes(box.lim_axes);
cla;
hold on;
sucess=0;
i=0;
while sucess==0&&i<length(box.list_proj_str);
    try
        m_proj(box.proj,'long',box.lon_lim,...
            'lat',box.lat_lim);
        sucess=1;
    catch
        i=i+1;
        fprintf(1,'Can''t use %s projection inside this area... Trying %s\n',box.proj,box.list_proj_str{i});
        box.proj_idx=i;
        box.proj=box.list_proj_str{box.proj_idx};
        set(box.tog_proj,'value',box.proj_idx);
    end
end
m_grid('box','fancy','tickdir','in');




box.plot=m_line(lon,lat,'Color','b ','linewidth',2,'tag','box','parent',box.lim_axes);
[lat_c,lon_c,bathy]=get_etopo1(box.lat_lim,box.lon_lim);

try
    
    if get(box.depth_box,'Value')>0
        vis='on';
    else
        vis='off';
    end
    if length(lon_c)>=2&&length(lat_c)>=2
        [box.Cs,box.hs]=m_contour(lon_c,lat_c,bathy,-10000:cont:-1,'edgecolor',[.4 .4 .4],'visible',vis);
    else
        box.Cs=[];
        box.hs=[];
    end
    
catch
    box.Cs=[];
    box.hs=[];
    disp('No Geographical data available...');
end

try
    if get(box.coast_box,'value')>=1
        m_gshhs_h('patch',[.5 .5 .5],'edgecolor','k','visible','on');
    else
        m_gshhs_h('patch',[.5 .5 .5],'edgecolor','k','visible','off','Tag');
    end
    
catch
    disp('No Geographical data available...')
end

index_selected = get(box.listbox,'Value');

for i=1:length(box.lat_lays)
    if ~isempty(box.lat_lays{i})
        if any(index_selected==i)
            box.trans(i)=m_plot(box.lon_lays{i},box.lat_lays{i},'color','r','linewidth',2,'linestyle','none','marker','.');
        else
            box.trans(i)=m_plot(box.lon_lays{i},box.lat_lays{i},'color','k','linewidth',1,'linestyle','none','marker','.');
        end
    end
end

m_ruler([0.1 0.3],0.1);

setappdata(map_fig,'Box',box);
create_box_impoints(map_fig,100);
end

function create_box_impoints(map_fig,i)
box=getappdata(map_fig,'Box');

[x_S_lim,y_S_lim]=m_ll2xy(nanmean(box.lon_lim),box.lat_lim(1));
[x_N_lim,y_N_lim]=m_ll2xy(nanmean(box.lon_lim),box.lat_lim(2));
[x_E_lim,y_E_lim]=m_ll2xy(box.lon_lim(2),nanmean(box.lat_lim));
[x_W_lim,y_W_lim]=m_ll2xy(box.lon_lim(1),nanmean(box.lat_lim));
[x_S,y_S]=m_ll2xy(nanmean(box.lon_box),box.lat_box(1));
[x_N,y_N]=m_ll2xy(nanmean(box.lon_box),box.lat_box(2));
[x_E,y_E]=m_ll2xy(box.lon_box(2),nanmean(box.lat_box));
[x_W,y_W]=m_ll2xy(box.lon_box(1),nanmean(box.lat_box));

try
    for ui=1:4
        if ui~=i
            delete(box.P(ui));
        end
    end
end

if i~=1
    box.P(1)=impoint(box.lim_axes,x_S,y_S);
end
if i~=2
    box.P(2)=impoint(box.lim_axes,x_N,y_N);
end
if i~=3
    box.P(3)=impoint(box.lim_axes,x_E,y_E);
end
if i~=4
    box.P(4)=impoint(box.lim_axes,x_W,y_W);
end

fcn{1}= makeConstrainToRectFcn('impoint',[x_S x_S],[y_S_lim y_N_lim]);
fcn{2}= makeConstrainToRectFcn('impoint',[x_N x_N],[y_S_lim y_N_lim]);
fcn{3}= makeConstrainToRectFcn('impoint',[x_W_lim x_E_lim],[y_E y_E]);
fcn{4}= makeConstrainToRectFcn('impoint',[x_W_lim x_E_lim],[y_W y_W]);

for ui=1:4
    box.P(ui).setPositionConstraintFcn(fcn{ui});
    if ui~=i
        setColor(box.P(ui),'k');
        addNewPositionCallback(box.P(ui),@(pos) update_map(pos,map_fig,ui));
    end
end

setappdata(map_fig,'Box',box);
end

function update_map(pos,map_fig,i)
box=getappdata(map_fig,'Box');
[lon_p,lat_p]=m_xy2ll(pos(1),pos(2));
switch i
    case 1
        box.lat_box(1)=lat_p;
    case 2
        box.lat_box(2)=lat_p;
    case 3
        box.lon_box(2)=lon_p;
    case 4
        box.lon_box(1)=lon_p;
end

for ui=1:4
    if ui~=i
        delete(box.P(ui));
    end
end
delete(box.plot);

[lon,lat]=create_box(box.lon_box,box.lat_box,box.nb_pts);
box.plot=m_line(lon,lat,'Color','b','linewidth',2,'tag','box','parent',box.lim_axes);
setappdata(map_fig,'Box',box);
create_box_impoints(map_fig,i);
end


function update_field_callback(~,~,map_fig)

box=getappdata(map_fig,'Box');

str_field=get(box.field,'string');
str_field=str_field{get(box.field,'value')};

switch (str_field)
    case 'SliceAbscf'
       box.val_max=0.00001;
    case 'Nb_ST'
       box.val_max=20;
    case 'Nb_Tracks'
       box.val_max=10;
    case 'Tag'
        box.val_max=0.00001;
end

set(box.val_max_box,'string',num2str(box.val_max,'%.6f'));
set(box.str_field,'String',sprintf('Max %s',str_field));
end




function update_map_callback(~,~,map_fig)

box=getappdata(map_fig,'Box');
index_selected = get(box.listbox,'Value');

axes(box.lim_axes);
for i=1:length(box.lat_lays)
    if any(index_selected==i)
        set(box.trans(i),'color','r','linewidth',2);
    else
        set(box.trans(i),'color','k','linewidth',1);
    end
end


childs=findall(box.lim_axes,'type','patch');

for i=1:length(childs)
    if contains(get(childs(i),'Tag'),'m_gshh')
        if get(box.coast_box,'value')>=1
            set(childs(i),'visible','on');
        else
            set(childs(i),'visible','off');
        end
    end
end

if get(box.depth_box,'Value')>0
    set(box.hs,'visible','on');
else
    set(box.hs,'visible','off');
end


end

function check_r_max(src,~,map_fig)
box=getappdata(map_fig,'Box');
str=get(src,'string');
if isnan(str2double(str))||str2double(str)<=0
    set(src,'string',num2str(box.r_max,'%.2f'));
else
    box.r_max=str2double(str);
    set(src,'string',num2str(box.r_max,'%.2f'));
end
setappdata(map_fig,'Box',box);
end

function check_val_max(src,~,map_fig)
box=getappdata(map_fig,'Box');
str=get(src,'string');
if isnan(str2double(str))||str2double(str)<=0
    set(src,'string',num2str(box.val_max,'%.8g'));
else
    box.val_max=str2double(str);
    set(src,'string',num2str(box.val_max,'%.8g'));
end
setappdata(map_fig,'Box',box);
end

function check_slice_size(src,~,map_fig)
box=getappdata(map_fig,'Box');
str=get(src,'string');
if isnan(str2double(str))||str2double(str)<=0
    set(src,'string',num2str(box.slice_size,'%d'));
else
    box.slice_size=ceil(str2double(str));
    set(src,'string',num2str(box.slice_size,'%d'));
end
setappdata(map_fig,'Box',box);
end


function check_depth_contour_size(src,~,map_fig)
box=getappdata(map_fig,'Box');
str=get(src,'string');
if isnan(str2double(str))||str2double(str)<=0
    set(src,'string',num2str(box.depth_contour_size,'%d'));
else
    box.depth_contour_size=ceil(str2double(str));
    set(src,'string',num2str(box.depth_contour_size,'%d'));
end
setappdata(map_fig,'Box',box);
init_map([],[],map_fig);
end


function create_map_callback(~,~,map_fig,main_fig,obj_vec_tot)

box=getappdata(map_fig,'Box');
hfigs=getappdata(main_fig,'ExternalFigures');
curr_disp=getappdata(main_fig,'Curr_disp');
index_selected = get(box.listbox,'Value');

if get(box.depth_box,'Value')>0
    cont=box.depth_contour_size;
else
    cont=0;
end

if isempty(obj_vec_tot)
    layers_tot=getappdata(main_fig,'Layers');
    obj=layers_tot(index_selected);
else
    obj=obj_vec_tot(index_selected);
end

if isempty(obj_vec_tot)
    map_input=map_input_cl.map_input_cl_from_obj(obj,'ValMax',box.val_max,'Rmax',box.r_max,'Proj',box.proj,'SliceSize',box.slice_size,'Coast',get(box.coast_box,'value'),'Depth_Contour',cont,'Freq',curr_disp.Freq);
    map_input.LatLim=sort(box.lat_box);
    map_input.LongLim=sort(box.lon_box);
else
    for ui=1:length(obj)
        map_input(ui)=map_input_cl.map_input_cl_from_obj(obj(ui),'ValMax',box.val_max,'Rmax',box.r_max,'Proj',box.proj,'SliceSize',box.slice_size,'Coast',get(box.coast_box,'value'),'Depth_Contour',cont);
        map_input(ui).LatLim=sort(box.lat_box);
        map_input(ui).LongLim=sort(box.lon_box);
    end
    map_input=map_input.concatenate_map_input();
end
str_field=get(box.field,'string');
str_field=str_field{get(box.field,'value')};

str_type=get(box.plottype,'string');
map_input.PlotType=str_type{get(box.plottype,'value')};
hfig=map_input.display_map_input_cl('main_figure',main_fig,'field',str_field);


hfigs_new=[hfigs hfig];
setappdata(main_fig,'ExternalFigures',hfigs_new);


end

