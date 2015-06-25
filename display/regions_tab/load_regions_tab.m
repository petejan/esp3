function load_regions_tab(main_figure,option_tab_panel)

if isappdata(main_figure,'Region_tab')
    region_tab_comp=getappdata(main_figure,'Region_tab');
    delete(region_tab_comp.region_tab);
    rmappdata(main_figure,'Region_tab');
end

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
if ~isempty(layer.Transceivers(idx_freq).GPSDataPing)
    dist=layer.Transceivers(idx_freq).GPSDataPing.Dist;
else
    dist=[];
end
list_reg = list_regions(layer.Transceivers(idx_freq));
region_tab_comp.region_tab=uitab(option_tab_panel,'Title','Regions');

if isempty(list_reg)
    list_reg={'--'};
end

uicontrol(region_tab_comp.region_tab,'Style','Text','String','Regions','units','normalized','Position',[0.5 0.8 0.1 0.1]);
region_tab_comp.tog_reg=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',list_reg,'Value',1,'units','normalized','Position', [0.6 0.8 0.3 0.1],'callback',{@tog_reg,main_figure});

uicontrol(region_tab_comp.region_tab,'Style','Text','String','Mode','units','normalized','Position',[0.5 0.6 0.1 0.1]);
region_tab_comp.mode=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',{'rectangular' 'vertical' 'horizontal'},'Value',1,'units','normalized','Position', [0.6 0.6 0.3 0.1]);


uicontrol(region_tab_comp.region_tab,'Style','Text','String','Cell Width','units','normalized','Position',[0 0.3 0.2 0.1]);
uicontrol(region_tab_comp.region_tab,'Style','Text','String','Cell Height','units','normalized','Position',[0 0.1 0.2 0.1]);

region_tab_comp.cell_w=uicontrol(region_tab_comp.region_tab,'Style','edit','unit','normalized','position',[0.2 0.3 0.05 0.1],'string',5,'Tag','w');
region_tab_comp.cell_h=uicontrol(region_tab_comp.region_tab,'Style','edit','unit','normalized','position',[0.2 0.1 0.05 0.1],'string',5,'Tag','h');

set([region_tab_comp.cell_w region_tab_comp.cell_h],'callback',{@check_cell,main_figure})
if ~isempty(dist)
    units_w= {'pings','meters'};
else
    units_w= {'pings'};
end

region_tab_comp.cell_w_unit=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',units_w,'Value',1,'units','normalized','Position', [0.3 0.3 0.1 0.1],'Tag','w');
region_tab_comp.cell_h_unit=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',{'meters','samples'},'Value',1,'units','normalized','Position', [0.3 0.1 0.1 0.1],'Tag','h');
region_tab_comp.cell_w_unit_curr=get(region_tab_comp.cell_w_unit,'value');
region_tab_comp.cell_h_unit_curr=get(region_tab_comp.cell_w_unit,'value');
set(region_tab_comp.cell_w_unit ,'callback',{@tog_units,main_figure});
set(region_tab_comp.cell_h_unit ,'callback',{@tog_units,main_figure});

%shape_type={'Vertical' 'Horizontal' 'Rectangular' 'Polygon'};
shape_type={'Rectangular' 'Polygon'};
%shape_type={'Rectangular'};
uicontrol(region_tab_comp.region_tab,'Style','Text','String','Shape','units','normalized','Position',[0 0.85 0.2 0.1]);
region_tab_comp.shape_type=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',shape_type,'Value',1,'units','normalized','Position', [0.2 0.85 0.2 0.1]);


data_type={'Data' 'Bad Data'};
uicontrol(region_tab_comp.region_tab,'Style','Text','String','Data Type','units','normalized','Position',[0 0.65 0.2 0.1]);
region_tab_comp.data_type=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',data_type,'Value',1,'units','normalized','Position', [0.2 0.65 0.2 0.1]);


ref={'Surface','Bottom'};
uicontrol(region_tab_comp.region_tab,'Style','Text','String','Reference','units','normalized','Position',[0 0.45 0.2 0.1]);
region_tab_comp.tog_ref=uicontrol(region_tab_comp.region_tab,'Style','popupmenu','String',ref,'Value',1,'units','normalized','Position', [0.2 0.45 0.2 0.1]);

uicontrol(region_tab_comp.region_tab,'Style','pushbutton','String','Disp. Reg 3D','units','normalized','pos',[0.425 0.1 0.15 0.15],'callback',{@display_region_3D,main_figure});
uicontrol(region_tab_comp.region_tab,'Style','pushbutton','String','Disp. Reg','units','normalized','pos',[0.625 0.1 0.15 0.15],'callback',{@display_region_callback,main_figure});
uicontrol(region_tab_comp.region_tab,'Style','pushbutton','String','Disp. Freq Response','units','normalized','pos',[0.825 0.1 0.15 0.15],'callback',{@freq_response_reg,main_figure});

region_tab_comp.create_button=uicontrol(region_tab_comp.region_tab,'Style','pushbutton','String','Create Region','units','normalized','pos',[0.525 0.3 0.15 0.15],'callback',{@create_region_callback,main_figure});
uicontrol(region_tab_comp.region_tab,'Style','pushbutton','String','Delete Region','units','normalized','pos',[0.725 0.3 0.15 0.15],'callback',{@delete_region_callback,main_figure});


setappdata(main_figure,'Region_tab',region_tab_comp);
end

function create_region_callback(src,~,main_figure)
reset_mode(0,0,main_figure);
set(main_figure,'WindowButtonDownFcn',{@create_region,main_figure});
end

function display_region_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = list_regions(layer.Transceivers(idx_freq));
idx_type=find_type_idx(layer.Transceivers(idx_freq).Data,'Sv');
cax=layer.Transceivers(idx_freq).Data.SubData(idx_type).CaxisDisplay;

if ~isempty(list_reg)
    active_reg=Transceiver.Regions(get(region_tab_comp.tog_reg,'value'));
    sv_disp=active_reg.Output.Sv_mean;
    %sv_disp(sv_disp<cax(1))=nan;
    if size(sv_disp,1)>1&&size(sv_disp,2)>1
        figure();
        subplot(2,1,1)
        pcolor(active_reg.Output.x_node,active_reg.Output.y_node,sv_disp)
        xlabel(sprintf('%s',active_reg.Cell_w_unit))
        ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
        shading interp
        caxis(cax);
        colorbar;
        colormap jet;
        axis ij
        hold on;
        subplot(2,1,2)
        plot(10*log10(nanmean(10.^(active_reg.Output.Sv_mean/10),2)),nanmean(active_reg.Output.y_node,2));
        grid on;
        xlabel('Sv mean')
        ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
        axis ij;
        grid on;
    else
        figure();
        subplot(2,1,1)
        plot(active_reg.Output.x_node,sv_disp)
        xlabel(sprintf('%s',active_reg.Cell_w_unit))
        ylabel('Sv mean')
        
        axis ij
        hold on;
        subplot(2,1,2)
        plot(sv_disp,active_reg.Output.y_node)
        grid on;
        xlabel('Sv mean')
        ylabel(sprintf('Depth (%s)',active_reg.Cell_h_unit));
        axis ij;
        grid on;
    end
else
    return
end

end


function delete_region_callback(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = list_regions(layer.Transceivers(idx_freq));

if ~isempty(list_reg)
    active_reg=Transceiver.Regions(get(region_tab_comp.tog_reg,'value'));
    layer.Transceivers(idx_freq).rm_region_name_id(active_reg.Name,active_reg.ID);
    list_reg = list_regions(layer.Transceivers(idx_freq));
    
    if ~isempty(list_reg)
        set(region_tab_comp.tog_reg,'value',1)
        set(region_tab_comp.tog_reg,'string',list_reg);
    else
        set(region_tab_comp.tog_reg,'value',1)
        set(region_tab_comp.tog_reg,'string',{'--'});
    end
    setappdata(main_figure,'Layer',layer);
    display_regions(main_figure);
else
    return
end
end

function tog_reg(~,~,main_figure)
layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');
curr_disp=getappdata(main_figure,'Curr_disp');

idx_freq=find_freq_idx(layer,curr_disp.Freq);

active_reg=get(region_tab_comp.tog_reg,'value');
list_name=get(region_tab_comp.tog_reg,'string');

switch list_name{active_reg}
    case '--'
        return
    otherwise
        reg_curr=layer.Transceivers(idx_freq).Regions(active_reg);
end
shape_types=get(region_tab_comp.shape_type,'string');
shape_type_idx=find(strcmp(reg_curr.Shape,shape_types));
set(region_tab_comp.shape_type,'value',shape_type_idx);

data_types=get(region_tab_comp.data_type,'string');
data_type_idx=find(strcmp(reg_curr.Type,data_types));
set(region_tab_comp.data_type,'value',data_type_idx);

refs=get(region_tab_comp.tog_ref,'string');
ref_idx=find(strcmp(reg_curr.Reference,refs));
set(region_tab_comp.tog_ref,'value',ref_idx);

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=find(strcmp(reg_curr.Cell_w_unit,w_units));
set(region_tab_comp.cell_w_unit,'value',w_unit_idx);

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=find(strcmp(reg_curr.Cell_h_unit,h_units));
set(region_tab_comp.cell_h_unit,'value',h_unit_idx);

cell_w=reg_curr.Cell_w;
set(region_tab_comp.cell_w,'string',cell_w);

cell_h=reg_curr.Cell_h;
set(region_tab_comp.cell_h,'string',cell_h);

display_regions(main_figure)
end

function check_cell(src,~,main_figure)
curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
dist=layer.Transceivers(idx_freq).GPSDataPing.Dist;

nb_pings=length(layer.Transceivers(idx_freq).Data.Number);
nb_samples=length(layer.Transceivers(idx_freq).Data.Range);

w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};


val=str2double(get(src,'string'));
if ~isnan(val)&&val>0
    
    switch get(src,'tag')
        case 'w'
            switch w_unit
                case 'pings'
                    if val>nb_pings/2
                        val=floor(nb_pings/2);
                    end
                case 'meters'
                    if val>dist(end)/2
                        val=floor(dist(end)/2);
                    end
            end
        case 'h'
            switch h_unit
                case 'samples'
                    if val>nb_samples/2
                        val=floor(nb_samples);
                    end
                    
                case 'meters'
                    if val>layer.Transceivers(idx_freq).Data.Range(end)/2
                        val=layer.Transceivers(idx_freq).Data.Range(end)/2;
                    end
            end
    end
    set(src,'string',num2str(val,'%.0f'));
else
    set(src,'string',5);
end


end

function tog_units(src,~,main_figure)

curr_disp=getappdata(main_figure,'Curr_disp');
layer=getappdata(main_figure,'Layer');
region_tab_comp=getappdata(main_figure,'Region_tab');

idx_freq=find_freq_idx(layer,curr_disp.Freq);
dist=layer.Transceivers(idx_freq).GPSDataPing.Dist;
dx=nanmean(diff(dist));
%pings=length(layer.Transceivers(idx_freq).Data.Number);
range=layer.Transceivers(idx_freq).Data.Range;
dr=nanmean(diff(range));
w_units=get(region_tab_comp.cell_w_unit,'string');
w_unit_idx=get(region_tab_comp.cell_w_unit,'value');
w_unit=w_units{w_unit_idx};

h_units=get(region_tab_comp.cell_h_unit,'string');
h_unit_idx=get(region_tab_comp.cell_h_unit,'value');
h_unit=h_units{h_unit_idx};

switch get(src,'tag')
    case 'w'
        if region_tab_comp.cell_w_unit_curr==w_unit_idx
            return;
        end
        val=str2double(get(region_tab_comp.cell_w,'string'));
        switch w_unit
            case 'pings'
                val=val/dx;
            case 'meters'
                val=val*dx;
                
        end
        region_tab_comp.cell_w_unit_curr=w_unit_idx;
        set(region_tab_comp.cell_w,'string',num2str(val,'%.0f'));
    case 'h'
        if region_tab_comp.cell_h_unit_curr==h_unit_idx
            return;
        end
        val=str2double(get(region_tab_comp.cell_h,'string'));
        switch h_unit
            case 'samples'
                val=val/dr;
            case 'meters'
                val=val*dr;
        end
        region_tab_comp.cell_h_unit_curr=h_unit_idx;
        set(region_tab_comp.cell_h,'string',num2str(val,'%.0f'));
end
setappdata(main_figure,'Region_tab',region_tab_comp);
end

function freq_response_reg(~,~,main_figure)

layer=getappdata(main_figure,'Layer');
curr_disp=getappdata(main_figure,'Curr_disp');
region_tab_comp=getappdata(main_figure,'Region_tab');
idx_freq=find_freq_idx(layer,curr_disp.Freq);
Transceiver=layer.Transceivers(idx_freq);
list_reg = list_regions(layer.Transceivers(idx_freq));

if ~isempty(list_reg)
    active_reg=Transceiver.Regions(get(region_tab_comp.tog_reg,'value'));
    idx_x0=double(layer.Transceivers(idx_freq).Data.Number(1)-1);
    
    idx_pings=active_reg.Ping_ori-idx_x0:(active_reg.Ping_ori-idx_x0+active_reg.BBox_w-1);
    idx_r=active_reg.Sample_ori:active_reg.Sample_ori+active_reg.BBox_h-1;
    
    switch(curr_disp.Type)
        case 'Sp'
            TS_freq_response_func(main_figure,idx_r,idx_pings)
        case 'Sv'
            Sv_freq_response_func(main_figure,idx_r,idx_pings)
    end
end


end
